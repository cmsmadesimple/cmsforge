module AccountHelper
  
  def find_projects_not_approved(user = nil)
    Project.find(:all, :conditions => ['state = ?', 'pending'], :order => 'created_at DESC')
  end
  
end
