class Notification::Sms < Notification::Base
  def mobile_number
    @params[:mobile_number]
  end

  def from
    @params[:from] || Figaro.env.twilio_from_number
  end

  def body
    @params[:body]
  end

  def to
    Rails.env.development? ? Figaro.env.twilio_to_number : mobile_number
  end

  def twilio_ssid
    Figaro.env.twilio_ssid
  end

  def twilio_token
    Figaro.env.twilio_token
  end

  def twilio
    Twilio::REST::Client.new twilio_ssid, twilio_token
  end

  def notify
    twilio.messages.create(from: from, to: to, body: body)
    Rails.logger.info "#{self}: to: #{to} body: #{body}"
    {}
  rescue Twilio::REST::RequestError => error
    handle_twilio_error(error)
  end

  protected

  def handle_twilio_error(error)
    Rollbar.warning(error)
    Rails.logger.error "ERROR: sms: #{error.class} ##{error.code}: #{error.message}"
    {}
  end
end
