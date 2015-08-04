class Notification::Mailer < ApplicationMailer
  default from: Settings.notification_mailer.default_from

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification.mailer.notification.subject
  #
  def notification(params)
    mail(params)
  end
end
