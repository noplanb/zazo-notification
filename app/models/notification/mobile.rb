class Notification::Mobile < Notification::Base
  REQUIRED_PARAMS = %w(subject device_build device_token device_platform payload).freeze

  attr_accessor :subject, :device_build, :device_token, :device_platform, :payload

  def self.description
    'Mobile notification for iOS or Android'
  end

  def do_notify
    GenericPushNotification.send_notification(notification_params)
  end

  protected

  def notification_params
    { platform: device_platform, token: device_token, payload: payload, type: :alert,
      build: device_build, content_available: true, alert: subject, badge: 1, }
  end
end
