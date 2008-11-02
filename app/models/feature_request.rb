class FeatureRequest < TrackerItem
  
  def send_email
    TrackerMailer.deliver_feature_request_update(self)
  end
  
end
