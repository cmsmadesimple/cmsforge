class ProjectJoinRequest < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :project
  
  acts_as_state_machine :initial => :pending
  state :pending, :after => :after_pending
  state :accepted, :after => :after_accepted
  state :rejected
  
  event :accept do
    transitions :to => :accepted, :from => :pending
  end
  
  event :reject do
    transitions :to => :rejected, :from => :pending
  end
  
  def after_pending
    delay.send_project_join_request
  end
  
  def after_accepted
    assign = Assignment.new
    assign.user_id = self.user_id
    assign.project_id = self.project_id
    assign.role = 'Member'
    assign.save
  end
  
  def send_project_join_request
    ProjectMailer.deliver_project_join_request(self)
  end
  
end
