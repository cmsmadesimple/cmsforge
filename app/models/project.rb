class Project < ActiveRecord::Base
  
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
  has_many :packages, :dependent => :destroy
  has_many :releases, :through => :packages, :order => 'id DESC', :dependent => :destroy
  has_many :valid_xml_files, :class_name => 'ReleasedFile', :finder_sql => 'SELECT released_files.* FROM released_files inner join releases on releases.id = released_files.release_id inner join packages on packages.id = releases.package_id WHERE released_files.filename LIKE \'%xml\' and packages.project_id = #{self.id} ORDER BY released_files.filename ASC', :counter_sql => 'SELECT count(released_files.*) FROM released_files inner join releases on releases.id = released_files.release_id inner join packages on packages.id = releases.package_id WHERE released_files.filename LIKE \'%xml\' and packages.project_id = #{self.id}', :readonly => true
  has_many :articles, :dependent => :destroy
  has_many :bugs, :dependent => :destroy
  has_many :feature_requests, :dependent => :destroy
  has_many :bug_versions, :dependent => :destroy
  has_many :project_join_requests, :dependent => :destroy
  
  belongs_to :license
  
  acts_as_commentable
  acts_as_taggable_on :tags
  
  scope :accepted, {:conditions => ['state = ?', 'accepted'], :order => 'name'}
  scope :non_alphabetical, {:conditions => ["name REGEXP ?", "^[^a-z]"], :order => 'name'}
  scope :starting_with, lambda{|letter|{:conditions => ["name LIKE ?", "#{letter}%"], :order => 'name'}}
  
  #acts_as_ferret :if => Proc.new { |project| project.state == 'accepted' }, :fields => { :name  => {:store => :true}, :unix_name => {:store => :true}, :description => {} }
  #is_indexed :fields => ['name', 'unix_name', 'description'],
    #:concatenate => [
      #{:association_name => "tags",
        #:field => "name",
        #:as => "tag_name",
        #:association_sql => "LEFT JOIN taggings ON (taggings.taggable_id=projects.id AND taggings.taggable_type='Project') LEFT JOIN tags ON taggings.tag_id=tags.id"}
    #],
    #:conditions => "state = 'accepted'"#,
  
  acts_as_state_machine :initial => :pending
  state :pending, :after => :after_pending
  state :accepted, :after => :after_accepted
  state :rejected, :after => :after_rejected
  state :hidden
  
  event :accept do
    transitions :to => :accepted, :from => :pending
  end
  
  event :reject do
    transitions :to => :rejected, :from => :pending
  end
  
  event :hide do
    transitions :to => :hidden, :from => [:accepted, :pending, :rejected]
  end
  
  event :show do
    transitions :to => :accepted, :from => :hidden
  end
  
  #validates_presence_of     :name, :unix_name, :description, :registration_reason, :project_type
  validates_presence_of     :name, :unix_name, :description, :registration_reason
  validates_length_of       :name, :within => 3..40, :allow_nil => true
  validates_length_of       :unix_name, :within => 3..15, :allow_nil => true
  validates_uniqueness_of   :name, :case_sensitive => false, :allow_nil => true
  validates_uniqueness_of   :unix_name, :case_sensitive => false, :allow_nil => true
  validates_format_of       :unix_name, :with => /^[a-z][a-z0-9_\-]+$/, :allow_nil => true
  
  def calculate_total_downloads
    count = 0
    self.releases.each do |release|
      release.released_files.each do |file|
        count = count + file.downloads
      end
    end
    self.downloads = count
    self.save
  end

	def stale?
		#if project is older than 6 mos, if project hasn't been committed to in 6 mos (or ever),
		#if project hasn't had a file release in 6 mos (or ever), if it's a module or a plugin
		#and if the freshness date is older than 6 mos
		amount_of_time = 12.months.ago
		
		if self.project_type == 'module' or self.project_type == 'plugin'
			if self.created_at < amount_of_time
				if self.last_repository_date.nil? or self.last_repository_date < amount_of_time
					if self.last_file_date.nil? or self.last_file_date < amount_of_time
						if self.freshness_date.nil? or self.freshness_date < amount_of_time
							return true
						end
					end
				end
			end
		end
		
		return false
	end
	
	def mark_not_stale!
    self.freshness_date = Time.now
    self.save
	end
  
  def should_index?
    self.state == 'accepted'
  end
  
  def home_page
    "/projects/#{self.unix_name}".html_safe
  end
  
  def name_and_home_page
    "<a href=\"#{self.home_page}\">#{self.name}</a>".html_safe
  end
  
  def repository_checkout_url(public = true)
    if public
      if self.repository_type == 'git'
        "git clone git://git.cmsmadesimple.org/#{self.unix_name}.git".html_safe
      elsif self.repository_type == 'github'
        "git clone git://github.com/#{self.github_repo}.git".html_safe
      else
        "svn checkout http://svn.cmsmadesimple.org/svn/#{self.unix_name}".html_safe
      end
    else
      if self.repository_type == 'git'
        "git clone git@git.cmsmadesimple.org:#{self.unix_name}.git".html_safe
      elsif self.repository_type == 'github'
        "git clone git@github.com:#{self.github_repo}.git".html_safe
      else
        "svn --username developername checkout http://svn.cmsmadesimple.org/svn/#{self.unix_name}".html_safe
      end
    end
  end
  
  def repository_browser_url
    if self.repository_type == 'git'
      "http://git.cmsmadesimple.org/?p=#{self.unix_name}.git;a=summary".html_safe
    elsif self.repository_type == 'github'
      "http://github.com/#{self.github_repo}".html_safe
    else
      "http://viewsvn.cmsmadesimple.org/listing.php?repname=#{self.unix_name}&path=%2F&sc=0".html_safe
    end
  end
  
  def approved_date
    #Projects coming over from gforge don't have an approved_on.  So we fake it.
    unless self.approved_on.nil?
      self.approved_on
    end
    return self.created_at
  end
  
  def after_pending
    send_later(:send_submission_email)
  end
  
  def after_accepted
    self.approved_on = Time.now
    #unless current_user.nil?
    #  self.approved_by = current_user.id
    #end
    self.save
    send_later(:create_repository)
    send_later(:send_acceptance_email)
  end
  
  def after_rejected
    send_later(:send_rejection_email)
  end
  
  def before_destroy
    unless self.state == "rejected"
      config = SimpleConfig.for(:application)
      if self.repository_type == 'git'
        system(config.drop_git_repos + "#{self.unix_name}")
      elsif self.repository_type == 'svn'
        system(config.drop_svn_repos + "#{self.unix_name}")
      end
    end
  end
  
  def send_submission_email
    ProjectMailer.deliver_project_submission(self)
  end
  
  def send_acceptance_email
    ProjectMailer.deliver_project_acceptance(self)
  end
  
  def send_rejection_email
    ProjectMailer.deliver_project_rejection(self)
    
    #Delete the project after the email is sent out
    self.destroy and return
  end
  
  def create_repository
    config = SimpleConfig.for(:application)
    if self.repository_type == 'git'
      system(config.create_git_repos + "#{self.unix_name}")
    elsif self.repository_type == 'svn'
      system(config.create_svn_repos + "#{self.unix_name}")
    end
  end
  
  def pending_join_requests
    ProjectJoinRequest.find(:all, :conditions => ['project_id = ? AND state = ?', self.id, 'pending'])
  end
  
  def has_join_request(user)
    ProjectJoinRequest.count(:conditions => ['user_id = ? AND project_id = ? AND state = ?', user.id, self.id, 'pending']) > 0
  end
  
  def latest_release
    newest = nil
    self.packages.each do |package|
      release = package.latest_release
      unless release.nil?
        if newest.nil?
          newest = release
        elsif newest.created_at <= release.created_at
          newest = release
        end
      end
    end
    
    newest
  end
  
end
