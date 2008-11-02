class TrackerMailer < ActionMailer::Base
  
  def bug_update(bug)
    
    config = SimpleConfig.for(:application)
    
    from "no-reply@cmsmadesimple.org"
    recipients ["no-reply@cmsmadesimple.org"]
    
    bcc_list = []    
    bcc_list << bug.created_by.email unless bug.created_by.nil?
    bug.project.users.each do |user|
      bcc_list << user.email unless user.nil? or user.email.nil?
    end
    #bug.project.followers.each do |user|
    #  bcc_list << user.email
    #end
    
    if config.send_bcc
      bcc bcc_list
    else
      cc ["ted@tedkulp.com"]
    end
    
    subject "[#{bug.project.name}-Bugs] [#{bug.id}] #{bug.summary}"
    
    content_type "text/plain"
    
    body :bug => bug, :url => config.host
    
  end
  
  def feature_request_update(feature_request)
    
    config = SimpleConfig.for(:application)
    
    from "no-reply@cmsmadesimple.org"
    recipients ["no-reply@cmsmadesimple.org"]
    
    bcc_list = []    
    bcc_list << feature_request.created_by.email unless feature_request.created_by.nil?
    feature_request.project.users.each do |user|
      bcc_list << user.email unless user.nil? or user.email.nil?
    end
    #feature_request.project.followers.each do |user|
    #  bcc_list << user.email
    #end
    
    if config.send_bcc
      bcc bcc_list
    else
      cc ["ted@tedkulp.com"]
    end
    
    subject "[#{feature_request.project.name}-Feature-Requests] [#{feature_request.id}] #{feature_request.summary}"
    
    content_type "text/plain"
    
    body :feature_request => feature_request, :url => config.host
    
  end

end
