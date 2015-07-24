class Notification::Sms < Notification::Base
  REQUIRED_PARAMS = %w(mobile_number body).freeze
  attr_accessor :mobile_number, :from, :body
  after_initialize :set_attributes

  validates :mobile_number, :body, :from, presence: true

  def self.description
    'SMS notification via Twilio'
  end

  def to
    Settings.stub_mobile_number ? Figaro.env.twilio_to_number : mobile_number
  end

  def twilio_ssid
    Figaro.env.twilio_ssid
  end

  def twilio_token
    Figaro.env.twilio_token
  end

  def twilio
    @twilio ||= Twilio::REST::Client.new twilio_ssid, twilio_token
  end

  def original_response
    JSON.parse(twilio.last_response.body)
  end

  def notify
    create_message
    log_success
    true
  rescue Twilio::REST::RequestError => error
    handle_twilio_error(error)
    false
  end

  def create_message
    twilio.messages.create(from: from, to: to, body: body)
  end

  protected

  def log_success
    Rails.logger.info "#{self}: to: #{to} body: #{body}"
  end

  def handle_twilio_error(error)
    Rollbar.warning(error)
    Rails.logger.error "ERROR: sms: #{error.class} ##{error.code}: #{error.message}"
    errors.add(:twilio, error.message)
  end

  def set_attributes
    @mobile_number = @params[:mobile_number]
    @from = @params[:from] || Figaro.env.twilio_from_number
    @body = @params[:body]
  end
end
