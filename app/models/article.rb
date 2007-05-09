class Article < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :author, :class_name => "User", :foreign_key => "submitted_by"
  
  validates_presence_of :title, :content, :package_id
  
  acts_as_activated
  acts_as_commentable
  
end
