# Preview all emails at http://localhost:3000/rails/mailers/notification/mailer
class Notification::MailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification/mailer/notification
  def notification
    Notification::Mailer.notification
  end

end
