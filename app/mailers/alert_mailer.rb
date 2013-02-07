class AlertMailer < ActionMailer::Base
  default from: "NoReply@escherhomewatch.com",
          content_type: "text/html"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def alert_email(subject, body, alert)
    @alert = alert
    @body = body
    mail :to => email_to, :subject => subject
  end
end
