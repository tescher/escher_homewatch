class AlertMailer < ActionMailer::Base
  # default from: "NoReply@eschers.com",
  #        content_type: "text/html"

  def alert_email(subject, body, email)
    @body = body
    mail :to => email, :subject => subject
  end
end
