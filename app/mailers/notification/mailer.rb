class Notification::Mailer < ApplicationMailer
  default from: Settings.notification_mailer.default_from

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification.mailer.notification.subject
  #
  def notification(params)
    subject = params[:subject]
    to = params[:to]
    from = params[:from] if params[:from]
    body = params[:body]

    mail from: from, to: to, subject: subject do |format|
      format.text { render text: body }
    end
  end
end
