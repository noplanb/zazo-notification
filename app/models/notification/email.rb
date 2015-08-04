class Notification::Email < Notification::Base
  REQUIRED_PARAMS = %w(to subject body).freeze
  EMAIL_REGEXP =  /<?[^@\s]+@([^@\s]+\.)+[^@\W]+>?/.freeze
  DEFAULT_FROM = Settings.notification_mailer.default_from.freeze
  DEFAULT_CONTENT_TYPE = 'text/html; charset=UTF-8'.freeze

  attr_accessor :from, :to, :subject, :body, :content_type
  attr_reader :delivery

  validates :to, :subject, :body, presence: true
  validates :to, format: { with: EMAIL_REGEXP }
  validates :content_type, inclusion: { in: MIME::Types,
                                        message: 'is not valid MIME type' }

  def self.description
    'Notification via Email over AWS'
  end

  def mail
    @mail ||= Notification::Mailer.notification(mail_params)
  end

  def do_notify
    @delivery = mail.deliver_now
  end

  def mail_params
    { from: from,
      to: to,
      subject: subject,
      body: body,
      content_type: content_type }
  end
  alias_method :event_data, :mail_params

  protected

  def set_attributes
    super
    @from = params.fetch(:from, DEFAULT_FROM)
    @to = params[:to]
    @subject = params[:subject]
    @body = params[:body]
    @content_type = params.fetch(:content_type, DEFAULT_CONTENT_TYPE)
  end
end
