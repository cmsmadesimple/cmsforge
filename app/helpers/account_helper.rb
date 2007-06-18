module AccountHelper
  
  def find_projects_not_approved(user = nil)
    Project.find_with_inactive(:all, :conditions => ['state = ?', 'pending'])
  end
  
end
