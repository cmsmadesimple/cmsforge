class User < ActiveRecord::Base
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable, :validatable, 
         :encryptable, :encryptor => :restful_authentication_sha1
  #acts_as_cached :version => 1
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :password, :password_confirmation, :remember_me, :full_name, :superuser

  has_many :assignments
  has_many :projects, :through => :assignments
  has_many :ssh_keys
  
  acts_as_follower

  include Gravtastic
  gravtastic :email

  def valid_password?(password)
    return false if encrypted_password.blank?
    Devise.secure_compare(Devise::Encryptors::Md5.digest(password, nil, nil, nil), self.encrypted_password)
  end
  
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
    self.email.gsub(/\./, [' (dot) ', ' (period) ', ' (daht) '].randomly_pick[0]).gsub(/@/, [' @no.spam@ ', ' @spam.sucks@ ', ' @spam.me.not@ ', ' (aht) '].randomly_pick[0]).html_safe
  end
  
  def home_url
    "/users/#{self.login}".html_safe
  end
  
  def name_and_link
    str = self.full_name.html_safe
    if self.login != 'None'
      str = str + " (<a href=\"#{self.home_url}\">#{self.login}</a>)".html_safe
    end
  end
  
  def name_and_link_no_nick
    str = self.full_name.html_safe
    if self.login != 'None'
      str = "<a href=\"#{self.home_url}\">#{self.full_name}</a>".html_safe
    end
  end
  
  def name_and_link_with_nick
    str = self.full_name.html_safe
    if self.login != 'None'
      str = "<a href=\"#{self.home_url}\">#{self.full_name} (#{self.login})</a>".html_safe
    end
  end
end
