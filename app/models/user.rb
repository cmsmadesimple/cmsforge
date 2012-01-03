require 'digest/sha1'
class User < ActiveRecord::Base
  
  acts_as_cached :version => 1
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_acceptance_of   :agree_to_forge_rules

  before_save :encrypt_password
  before_create :make_activation_code
  
  after_save :expire_cache
  
  has_many :assignments
  has_many :projects, :through => :assignments
  has_many :ssh_keys
  
  acts_as_follower
  
  def member_of?(project)
    if self.superuser
      return true
    end
    
    self.assignments.each do |assignment|
      if assignment.project_id == project.id
        return true
      end
    end
    
    return false
  end
  
  def admin_of?(project)
    if self.superuser
      return true
    end
    
    self.assignments.each do |assignment|
      if assignment.project_id == project.id and assignment.role == 'Administrator'
        return true
      end
    end
    
    return false
  end
  
  def email_replaced
    self.email.gsub(/\./, [' (dot) ', ' (period) ', ' (daht) '].randomly_pick[0]).gsub(/@/, [' @no.spam@ ', ' @spam.sucks@ ', ' @spam.me.not@ ', ' (aht) '].randomly_pick[0]);
  end
  
  def home_url
    "/users/#{self.login}"
  end
  
  def name_and_link
    str = self.full_name
    if self.login != 'None'
      str = str + " (<a href=\"#{self.home_url}\">#{self.login}</a>)"
    end
  end
  
  def name_and_link_no_nick
    str = self.full_name
    if self.login != 'None'
      str = "<a href=\"#{self.home_url}\">#{self.full_name}</a>"
    end
  end
  
  def name_and_link_with_nick
    str = self.full_name
    if self.login != 'None'
      str = "<a href=\"#{self.home_url}\">#{self.full_name} (#{self.login})</a>"
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::MD5.hexdigest(password)
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end

  def recently_reset_password?
    @reset_password
  end

  def recently_forgot_password?
    @forgotten_password
  end
  
  def self.find_for_forgot(email)
    find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      #self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

end
