class TrackerItem < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_id"
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :bug_version, :class_name => "BugVersion", :foreign_key => "version_id"
  belongs_to :version, :class_name => "BugVersion", :foreign_key => "version_id"
  belongs_to :cmsms_version, :class_name => "BugVersion", :foreign_key => "cmsms_version_id"
  belongs_to :severity, :class_name => 'BugSeverity', :foreign_key => 'severity_id'
  belongs_to :resolution, :class_name => 'BugResolution', :foreign_key => 'resolution_id'
  
  validates_presence_of :summary, :description, :created_by, :project_id
  
  acts_as_cached
  acts_as_commentable
  
  has_paper_trail

  cattr_reader :per_page
  @@per_page = 25
  
  def assigned_to_string
    self.assigned_to_id > 0 ? User.find(self.assigned_to_id).full_name : 'None'
  end
  
  def created_by_string
    self.created_by_id > 0 ? User.find(self.created_by_id).full_name : 'None'
  end
  
  def resolution_string
    !self.resolution.nil? ? self.resolution.name : 'None'
  end
  
  def state_string
    !self.state.nil? ? self.state : 'None'
  end
  
  def after_save
    delay.send_email
  end

  def changes
    # Use this to get the old history
    TrackerItem.acts_as_historizable

    out = {}
    versions.reverse.each do |version|
      if version.event == 'update'
        out[version] = {}
        model = version.reify
        next_model = version.next ? version.next.reify : self
        model.attributes.each do |key,val|
          if key != 'updated_at' and !val.nil? and model[key].to_s != next_model[key].to_s
            out[version][cleanup_key(key)] = (realize_value(model, key, val).to_s + ' <strong>-&gt;</strong> ' + realize_value(next_model, key, val).to_s).html_safe
          end
        end
      end
    end

    histories.each do |h|
      out[h] = {}
      h.history_lines.each do |h1|
        out[h][cleanup_key(h1.field_name)] = (h1.field_value_was + ' <strong>-&gt;</strong> ' + h1.field_value_actual).html_safe
      end
    end

    out
  end

  def cleanup_key(key)
    if key.end_with?('_id')
      key = key.gsub('_id', '')
    end
    key.titleize
  end

  def realize_value(model, key, value)
    begin
      case key
      when 'assigned_to_id'
        model.assigned_to.full_name
      when 'version_id'
        model.bug_version.name
      when 'severity_id'
        model.severity.name
      when 'resolution_id'
        model.resolution.name
      when 'cmsms_version_id'
        model.cmsms_version.name
      else
        model.send(key.to_sym)
      end
    rescue
      'nil'
    end
  end

end
