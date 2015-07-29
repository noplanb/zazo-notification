class Notification::Sms < Notification::Base
  REQUIRED_PARAMS = %w(mobile_number body).freeze
  attr_accessor :mobile_number, :from, :body

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

  def do_notify
    twilio.messages.create(from: from, to: to, body: body)
  end

  protected

  def set_attributes
    super
    @mobile_number = @params[:mobile_number]
    @from = @params[:from] || Figaro.env.twilio_from_number
    @body = @params[:body]
  end

  def event_data
    { from: from,
      to: to,
      body: body }
  end
end
