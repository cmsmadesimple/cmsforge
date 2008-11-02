class Bug < TrackerItem
  
  def send_email
    TrackerMailer.deliver_bug_update(self)
  end
  
end
