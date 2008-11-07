class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://devnew.cmsmadesimple.org/account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://devnew.cmsmadesimple.org/"
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "noreply@cmsmadesimple.org"
    @subject     = "Welcome to the CMSMS Developer Forge"
    @sent_on     = Time.now
    @body[:user] = user
  end
end
