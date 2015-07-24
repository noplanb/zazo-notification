class VerificationCodeSender
  TWILIO_INVALID_NUMBER_ERRORS = {
    21211 => "Invalid 'To' Phone Number",
    21214 => "'To' phone number cannot be reached",
    21217 => 'Phone number does not appear to be valid',
    21219 => "'To' phone number not verified",
    21401 => 'Invalid Phone Number',
    21407 => 'This Phone Number type does not support SMS or MMS',
    21421 => 'PhoneNumber is invalid',
    21601 => 'Phone number is not a valid SMS-capable/MMS-capable inbound phone number',
    21604 => "'To' phone number is required to send a Message",
    21612 => "The 'To' phone number is not currently reachable via SMS",
    21614 => "'To' number is not a valid mobile number",
    21615 => 'PhoneNumber Requires a Local Address',
    21624 => 'PhoneNumber Requires a Foreign Address'
  }

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def send_code
    cc_iso = GlobalPhone.parse(user.mobile_number).territory.name
    sms_country?(cc_iso) ? send_verification_sms : make_verification_call
  end

  def sms_country?(cc_iso)
    Settings.verification_code_sms_countries.include? cc_iso.downcase
  end

  def from
    Figaro.env.twilio_from_number
  end

  def to
    Rails.env.development? ? Figaro.env.twilio_to_number : user.mobile_number
  end

  def message
    "#{Settings.app_name} access code: #{user.get_verification_code}"
  end

  def twilio_invalid_number?(code)
    TWILIO_INVALID_NUMBER_ERRORS.keys.include?(code.to_i)
  end

  def twilio
    Twilio::REST::Client.new Figaro.env.twilio_ssid, Figaro.env.twilio_token
  end

  def twilio_call_url
    Rails.application.routes.url_helpers.verification_code_say_code_url
  end

  def twilio_call_fallback_url
    Rails.application.routes.url_helpers.verification_code_call_fallback_url
  end

  def send_verification_sms
    user.pend! if user.may_pend?
    twilio.messages.create(from: from, to: to, body: message)
    user.register!
    Rails.logger.info "send_verification_sms: to:#{to} msg:#{message}"
    :ok
  rescue Twilio::REST::RequestError => error
    handle_twilio_error(error)
  end

  def make_verification_call
    user.pend! if user.may_pend?
    twilio.calls.create(
      from: from,
      to: to,
      url: twilio_call_url,
      method: 'GET',
      fallback_url: twilio_call_fallback_url
    )
    user.register!
    Rails.logger.info "make_verification_call: to:#{to}"
    :ok
  rescue Twilio::REST::RequestError => error
    handle_twilio_error(error)
  end

  def handle_twilio_error(error)
    user.fail_to_register!
    Rollbar.warning(error)
    Rails.logger.error "ERROR: make_verification_call: #{error.class} ##{error.code}: #{error.message}"
    twilio_invalid_number?(error.code) ? :invalid_mobile_number : :other
  end
end
