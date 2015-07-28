class Notification::Email < Notification::Base
  REQUIRED_PARAMS = %w(recipient subject body).freeze
  attr_accessor :sender, :recipient, :subject, :body

  validates :recipient, :subject, :body, presence: true

  def self.description
    'Notification via Email over AWS'
  end

  def do_notify
    Notification::Mailer.notification(mail_params).deliver_now
  end

  protected

  def mail_params
    { sender: sender,
      recipient: recipient,
      subject: subject,
      body: body }
  end

  def set_attributes
    super
    @sender = params[:sender] || Settings.notification_mailer.default_from
    @recipient = params[:recipient]
    @subject = params[:subject]
    @body = params[:body]
  end
end
