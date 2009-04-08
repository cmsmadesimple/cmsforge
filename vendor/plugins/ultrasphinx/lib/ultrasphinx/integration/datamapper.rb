module Ultrasphinx::DataMapperExtensions
  def set_distance(dist)
    @distance = dist
    
  end
  
  def distance
    @distance || super
  end  
end

require 'ostruct'
class OpenStruct
  # openstruct, you suck for not subclassing from blankslate,
  # or at least cleaning up deprecated methods for me  
  def type
    @table[:type]
  end
end

module Ultrasphinx::ActiveRecordImpersonation
  def table_name
    storage_name
  end

  def primary_key
    key.first.name
  end

  def connection
    repository.adapter
  end
  
  def property_type_mapping(klass)
    case klass.to_s
    when 'TrueClass', 'DataMapper::Types::Boolean', 'DataMapper::Types::ParanoidBoolean'
      :boolean
    when 'String'
      :string
    when 'DataMapper::Types::Text'
      :text
    when 'Float'
      :float
    when 'Fixnum', 'Integer'
      :integer
    when 'DateTime', 'DataMapper::Types::ParanoidDateTime'
      :datetime
    when 'Date'
      :date
    else
      raise "Unknown column type: #{klass}"
    end
  end
  
  def columns_hash
    properties.to_a.inject({}) do |hsh, property|
      hsh[property.name.to_s] = OpenStruct.new(
        :type => property_type_mapping(property.type)
      )
      hsh
    end
  end

  def find_all_by_id(ids)
    all(:id => ids)
  end
  
  def [](id)
    get(id)
  end
  
  def reflect_on_all_associations
    # Datamapper, you're crazy...
    relationships.map { |name, relationship|
      if relationship.options[:min].nil?
        macro = :belongs_to
        if relationship.options[:class_name]
          # In a belongs_to, the side with the class name uses
          # the parent model, but child key for the foreign key...
          class_name = relationship.parent_model.to_s
          primary_key_name = relationship.child_key.entries.first.name
        else
          class_name = relationship.child_model.to_s
          primary_key_name = relationship.parent_key.entries.first.name
        end
      else
        macro = :has_one
        if relationship.options[:class_name]
          # but on the has_one side, it's the *child* model that
          # uses the child key for the foreign key.  Weirdness.
          class_name = relationship.child_model.to_s
          primary_key_name = relationship.child_key.entries.first.name
        else
          class_name = relationship.parent_model.to_s
          primary_key_name = relationship.parent_key.entries.first.name
        end
      end
      OpenStruct.new(
        :name => name,
        :class_name => class_name,
        :primary_key_name => primary_key_name,
        :macro => macro
      )
    }
  end
end

module DataMapper::Resource
  include Ultrasphinx::DataMapperExtensions
  module ClassMethods
    include Ultrasphinx::IsIndexed
    include Ultrasphinx::ActiveRecordImpersonation
  end
end

module DataMapper
  module Adapters  
    class AbstractAdapter
      def get_facets(*args)
        query(*args).map{|result| result.values}
      end

      def instance_variable_get(ivar)
        # Wow, this is a *horrible* hack...
        if ivar == '@config'
          config = {
            :adapter  => uri.scheme,
            :username => uri.user,
            :password => uri.password,
            :host     => uri.host,
            # why the default port needs to be a string but database needs to be keyed a symbol, I dunno
            'port'    => uri.port,
            :database => uri.path[1..-1] # strip leading '/'
          }
          config.keys.each do |key|
            config.delete(key) if config[key].nil?
          end
          config
        else
          super
        end
      end
    end
  end
end

module ActiveRecord
  class ActiveRecordError < StandardError; end
  class RecordNotFound < ActiveRecordError; end
end
