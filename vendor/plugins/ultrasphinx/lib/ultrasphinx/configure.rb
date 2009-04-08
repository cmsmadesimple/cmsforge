module Ultrasphinx
  class Configure
    class << self
      # Force all the indexed models to load and register in the MODEL_CONFIGURATION hash.
      def load_constants
        Dir.chdir "#{ROOT}/app/models/" do
          Dir["**/*.rb"].each do |filename|
            open(filename) do |file|
              begin
                if file.grep(/^\s+is_indexed/).any?
                  filename = filename[0..-4]
                  begin
                    File.basename(filename).camelize.constantize
                  rescue NameError => e
                    filename.camelize.constantize
                  end
                end
              rescue Object => e
                Ultrasphinx.say "warning: critical autoload error on #{filename}; try referencing \"#{filename.camelize}\" directly in the console"
                #Ultrasphinx.say e.backtrace.join("\n") if ENV == "development"
              end
            end
          end
        end

        # Build the field-to-type mappings.
        Fields.instance.configure(MODEL_CONFIGURATION)
      end
    end
    
    # Main SQL builder.
    def run
      Ultrasphinx::Configure.load_constants

      Ultrasphinx.say "rebuilding configurations for #{ENV} environment"
      Ultrasphinx.say "available models are #{MODEL_CONFIGURATION.keys.to_sentence}"
      File.open(CONF_PATH, "w") do |conf|
        conf.puts self.to_s
      end
    end
    
    def to_s
      Ultrasphinx.say "generating SQL"
      (global_header + index_configuration).join("\n")
    end
    
    def global_header
      [ "",
        "# Auto-generated at #{Time.now}.",
        "# Hand modifications will be overwritten.",
        "# #{BASE_PATH}",
        INDEXER_SETTINGS.except('delta')._to_conf_string('indexer').chomp,
        "",
        DAEMON_SETTINGS._to_conf_string("searchd").chomp]
    end

    def index_configuration
      INDEXES.map{|i| IndexConfiguration.new(i).to_s}
    end
  end

  class IndexConfiguration
    def initialize(name)
      @name = name
    end
    
    def config
      @sources = {}
      MODEL_CONFIGURATION.each_with_index do |model_and_options, class_id|
        model, options = model_and_options
        process_source(model, options, class_id)
      end
      @sources.keys.sort.map{|k| @sources[k] } + index_config
    end
    
    def process_source(model, options, class_id)
      source = SourceConfiguration.new(@name, model, class_id, options)
      if source.config?
        @sources[source.name] = source.config
      end
    end
    
    def to_s
      config.flatten.map{|line|line.chomp}.join("\n")
    end

    def index_config
      return [] if @sources.empty? # no sources, skip summary as well
      [ "",
        "# Index configuration",
        "",
        "index #{@name}",
        "{",
        @sources.keys.sort.map do |source|
          "  source = #{source}"
        end.join("\n"),
        INDEX_SETTINGS.merge('path' => INDEX_SETTINGS['path'] + "/sphinx_index_#{@name}")._to_conf_string,
        "}",
        ""
      ]
    end
  end

  class SourceConfiguration
    include Associations

    def initialize(index_name, model, class_id, options)
      @index_name = index_name
      @model = model
      @klass = model.constantize
      @source = "#{model.tableize.gsub('/', '__')}_#{@index_name}"
      @class_id = class_id
      @options = options
      @groups = Fields.instance.groups.join("\n")
      
      build_config if config?
    end
    
    def name
      @source
    end
    
    def config?
      # This relies on hash sort order being deterministic per-machine
      @index_name != DELTA_INDEX or @options['delta']
    end
    
    def config
      [ "",
        "# Source configuration",
        "",
        "source #{@source}",
        "{",
        SOURCE_SETTINGS._to_conf_string,
        source_database_string,
        range_select_string,
        query_string,
        "",
        @groups,
        query_info_string,
        "}",
        ""]
    end

  private
    def index?
      @index_name == DELTA_INDEX and @options['delta']
    end
  
    def build_config
      init_config
      build_class_columns
      build_delta_condition
      build_regular_fields
      build_includes
      build_concatenations
      add_missing_columns
    end
    
    def init_config
      @column_strings = []
      @join_strings = []
      @condition_strings = Array(@options['conditions']).map{|condition| "(#{condition})"}
      @group_bys = []
      @use_distinct = false
      @remaining_columns = Fields.instance.types.keys
      @order = @options['order']
    end

    def build_class_columns
      @column_strings << "(#{@klass.table_name}.#{@klass.primary_key} * #{MODEL_CONFIGURATION.size} + #{@class_id}) AS id"
      @column_strings << "#{@class_id} AS class_id"
      @column_strings << "'#{@klass.name}' AS class"
      @remaining_columns -= ["class", "class_id"]
    end

    def build_delta_condition
      return unless index?

      # Add delta condition if necessary
      table, field = @klass.table_name, @options['delta']['field']
      source_string = "#{table}.#{field}"
      delta_column = @klass.columns_hash[field]
      
      unless delta_column
        Ultrasphinx.say "warning; #{@klass.name} will reindex the entire table during delta indexing"
        return
      end
      raise ConfigurationError, "#{source_string} is not a :datetime" unless delta_column.type == :datetime
      raise ConfigurationError, "No 'indexer { delta }' setting specified in '#{BASE_PATH}'" unless INDEXER_SETTINGS['delta']

      if (@options['fields'] + @options['concatenate'] + @options['include']).detect { |entry| entry['sortable'] }
        # Warning about the sortable problem
        # XXX Kind of in an odd place, but I want to happen at index time
        Ultrasphinx.say "warning; text sortable columns on #{@klass.name} will return wrong results with partial delta indexing"
      end

      @condition_strings << @delta_condition = "#{source_string} > #{SQL_FUNCTIONS[ADAPTER]['delta']._interpolate(INDEXER_SETTINGS['delta'])}"
    end

    def build_regular_fields
      @options['fields'].to_a.each do |entry|
        @group_bys << source_string = "#{entry['table_alias']}.#{entry['field']}"
        install_field(source_string, entry['as'], entry['function_sql'], entry['facet'], entry['sortable'])
      end
    end

    def build_includes
      @options['include'].to_a.each do |entry|
        raise ConfigurationError, "You must identify your association with either class_name or association_name, but not both" if entry['class_name'] && entry ['association_name']

        association = get_association(@klass, entry)

        # You can use 'class_name' and 'association_sql' to associate to a model that doesn't actually
        # have an association.
        join_klass = association ? association.class_name.constantize : entry['class_name'].constantize

        raise ConfigurationError, "Unknown association from #{@klass} to #{entry['class_name'] || entry['association_name']}" if not association and not entry['association_sql']

        install_join_unless_association_sql(entry['association_sql']) do
          "LEFT OUTER JOIN #{join_klass.table_name} AS #{entry['table_alias']} ON " +
          if (macro = association.macro) == :belongs_to
            "#{entry['table_alias']}.#{join_klass.primary_key} = #{@klass.table_name}.#{association.primary_key_name}"
          elsif macro == :has_one
            "#{@klass.table_name}.#{@klass.primary_key} = #{entry['table_alias']}.#{association.primary_key_name}"
          else
            raise ConfigurationError, "Unidentified association macro #{macro.inspect}. Please use the :association_sql key to manually specify the JOIN syntax."
          end
        end

        source_string = "#{entry['table_alias']}.#{entry['field']}"
        @group_bys << source_string
        install_field(source_string, entry['as'], entry['function_sql'], entry['facet'], entry['sortable'])
      end
    end

    def build_concatenations
      @options['concatenate'].to_a.each do |entry|
        if entry['field']
          # Group concats

          # Only has_many's or explicit sql right now.
          association = get_association(@klass, entry)

          # You can use 'class_name' and 'association_sql' to associate to a model that doesn't actually
          # have an association. The automatic choice of a table alias chosen might be kind of strange.
          join_klass = association ? association.class_name.constantize : entry['class_name'].constantize

          install_join_unless_association_sql(entry['association_sql']) do
            # XXX The foreign key is not verified for polymorphic relationships.
            association = get_association(@klass, entry)
            "LEFT OUTER JOIN #{join_klass.table_name} AS #{entry['table_alias']} ON #{@klass.table_name}.#{@klass.primary_key} = #{entry['table_alias']}.#{association.primary_key_name}" +
              # XXX Is this valid?
              (entry['conditions'] ? " AND (#{entry['conditions']})" : "")
          end

          source_string = "#{entry['table_alias']}.#{entry['field']}"
          order_string = ("ORDER BY #{entry['order']}" if entry['order'])
          # We are using the field in an aggregate, so we don't want to add it to group_bys
          source_string = SQL_FUNCTIONS[ADAPTER]['group_concat']._interpolate(source_string, order_string)
          @use_distinct = true

          install_field(source_string, entry['as'], entry['function_sql'], entry['facet'], entry['sortable'])

        elsif entry['fields']
          # Regular concats
          source_string = "CONCAT_WS(' ', " + entry['fields'].map do |subfield|
            "#{entry['table_alias']}.#{subfield}"
          end.each do |subsource_string|
            @group_bys << subsource_string
          end.join(', ') + ")"

          install_field(source_string, entry['as'], entry['function_sql'], entry['facet'], entry['sortable'])

        else
          raise ConfigurationError, "Invalid concatenate parameters for #{model}: #{entry.inspect}."
        end
      end
    end

    def add_missing_columns
      @remaining_columns.each do |field|
        @column_strings << Fields.instance.null(field)
      end
    end

    def install_field(source_string, as, function_sql, with_facet, with_sortable)
      source_string = function_sql._interpolate(source_string) if function_sql

      @column_strings << Fields.instance.cast(source_string, as)
      @remaining_columns.delete(as)

      # Generate duplicate text fields for sorting
      if with_sortable
        @column_strings << Fields.instance.cast(source_string, "#{as}_sortable")
        @remaining_columns.delete("#{as}_sortable")
      end

      # Generate hashed integer fields for text grouping
      if with_facet
        @column_strings << "#{SQL_FUNCTIONS[ADAPTER]['hash']._interpolate(source_string)} AS #{as}_facet"
        @remaining_columns.delete("#{as}_facet")
      end
    end

    def source_database_string
      # Supporting Postgres now
      connection_settings = @klass.connection.instance_variable_get("@config")
      raise ConfigurationError, "Unsupported database adapter" unless connection_settings

      adapter_defaults = DEFAULTS[ADAPTER]
      raise ConfigurationError, "Unsupported database adapter" unless adapter_defaults

      conf = [adapter_defaults]
      connection_settings.reverse_merge(CONNECTION_DEFAULTS).each do |key, value|
        conf << "#{CONFIG_MAP[key]} = #{value}" if CONFIG_MAP[key]
      end
      conf.sort.join("\n")
    end

    def range_select_string
      ["sql_query_range = SELECT",
        SQL_FUNCTIONS[ADAPTER]['range_cast']._interpolate("MIN(#{@klass.primary_key})"),
        ",",
        SQL_FUNCTIONS[ADAPTER]['range_cast']._interpolate("MAX(#{@klass.primary_key})"),
        "FROM #{@klass.table_name}",
        ("WHERE #{@delta_condition}" if @delta_condition),
      ].join(" ")
    end

    def query_string
      primary_key = "#{@klass.table_name}.#{@klass.primary_key}"
      group_bys = case ADAPTER
        when 'mysql'
          primary_key
        when 'postgresql'
          # Postgres is very fussy about GROUP_BY
          ([primary_key] + @group_bys.reject {|s| s == primary_key}.uniq.sort).join(', ')
        end

      ["sql_query =",
        "SELECT",
        # Avoid DISTINCT; it destroys performance
        @column_strings.sort_by do |string|
          # Sphinx wants them always in the same order, but "id" must be first
          (field = string[/.*AS (.*)/, 1]) == "id" ? "*" : field
        end.join(", "),
        "FROM #{@klass.table_name}",
        @join_strings.uniq,
        "WHERE #{primary_key} >= $start AND #{primary_key} <= $end",
        @condition_strings.uniq.map {|condition| "AND #{condition}" },
        "GROUP BY #{group_bys}",
        ("ORDER BY #{@order}" if @order)
      ].flatten.compact.join(" ")
    end

    def query_info_string
      "sql_query_info = SELECT * FROM #{@klass.table_name} WHERE #{@klass.table_name}.#{@klass.primary_key} = (($id - #{@class_id}) / #{MODEL_CONFIGURATION.size})"
    end

    def install_join_unless_association_sql(association_sql=nil, join_string=nil)
      @join_strings << (association_sql or join_string or yield)
    end
  end
  
end
