class Notification::Email < Notification::Base
  REQUIRED_PARAMS = %w(to subject body).freeze
  attr_accessor :from, :to, :subject, :body

  validates :to, :subject, :body, presence: true

  def self.description
    'Notification via Email over AWS'
  end

  def do_notify
    @mail = Notification::Mailer.notification(mail_params).deliver_now
  end

  def original_response
    @mail.try(:header_fields)
  end

  protected

  def mail_params
    { from: from,
      to: to,
      subject: subject,
      body: body }
  end

  def set_attributes
    super
    @from = params[:from] || Settings.notification_mailer.default_from
    @to = params[:to]
    @subject = params[:subject]
    @body = params[:body]
  end
end