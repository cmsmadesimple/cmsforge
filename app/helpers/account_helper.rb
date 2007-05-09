module AccountHelper
  
  def find_projects_not_approved
    Project.find_with_inactive(:all, :conditions => ['state = ?', 'pending'])
  end
  
end
