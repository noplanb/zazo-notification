class Notification::Mobile < Notification::Base
  REQUIRED_PARAMS = %w(subject device_build device_token device_platform payload).freeze
  ALLOWED_DEVICE_PLATFORMS = %w(ios android)
  ALLOWED_DEVICE_BUILDS    = %w(dev prod)

  attr_reader   :response
  attr_accessor :subject, :device_token, :device_platform, :payload, :device_build
  validates     :subject, :device_token, :device_platform, :payload, presence: true
  validates     :device_platform, inclusion: { in: ALLOWED_DEVICE_PLATFORMS, message: 'is not valid device platform' }
  validates_with DeviceBuildValidator
  validates_with PayloadStructureValidator

  def self.description
    'Mobile notification for iOS or Android'
  end

  def do_notify
    results = GenericPushNotification.send_notification(notification_params)
    device_platform == 'ios' ? handle_ios_results(results) : handle_android_results(results)
  end

  def original_response
    @response
  end

  protected

  def set_attributes
    super
    @subject = params[:subject]
    @device_build = params[:device_build]
    @device_token = params[:device_token]
    @device_platform = params[:device_platform]
    @payload = payload_with_required_attrs params[:payload]
  end

  private

  def handle_ios_results(results)
    @response = results
    response[:status] == :failure && self.errors.add(:response, response[:error])
  end

  def handle_android_results(results)
    if results.kind_of? Faraday::Response
      @response = results.body
      response['failure'] == 1 && self.errors.add(:response, response['results'][0]['error'])
    else
      self.errors.add(:response, 'response body in not exist, possible server error')
    end
  end

  def notification_params
    { platform: device_platform,
      token: device_token,
      type: :alert,
      build: device_build,
      content_available: true,
      alert: subject,
      badge: 1,
      payload: payload }
  end

  def payload_with_required_attrs(attrs)
    attrs.kind_of?(Hash) ? wrap_params(attrs.merge(host: Figaro.env.zazo_domain_name)) : attrs
  end
end
