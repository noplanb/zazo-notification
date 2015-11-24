class GenericPushNotification
  # :build = :dev, :prod (for IOS only)
  attr_accessor :platform, :token, :type, :payload,          # ios and android
                :alert, :badge, :sound, :content_available, :build   # ios only

  # include EnumHandler
  # define_enum :platform, [:ios,:android]
  # define_enum :type, [:alert, :silent] # Only relevant for ios

  def self.send_notification(attributes = {})
    new(attributes).send_notification
  end

  def initialize(attrs = {})
    @build = attrs[:build] || :dev
    @token = attrs[:token] || fail("#{self.class.name}: token required.")
    @platform = attrs[:platform] || :android
    @type = attrs[:type] || :silent
    @alert = attrs[:alert] unless @type == :silent
    @badge = attrs[:badge] unless @type == :silent
    @sound = attrs[:sound] || (@type == :silent ? nil : 'NotificationTone.wav')
    @content_available = attrs[:content_available].present?
    @payload = attrs[:payload]
  end

  def ios_notification
    @notification ||= Houston::Notification.new(device: @token).tap do |n|
      n.alert = @alert if @alert
      n.badge = @badge if @badge
      n.sound = @sound if @sound
      n.content_available = @content_available
      n.custom_data = @payload if @payload
    end
  end

  def apns
    @client ||= begin
      if @build == :prod
        client = Houston::Client.production
        client.certificate = File.read(Rails.root.join('certs/zazo_aps_prod.pem'))
      else
        client = Houston::Client.development
        client.certificate = File.read(Rails.root.join('certs/zazo_aps_dev.pem'))
      end
      client
    end
  end

  def send_notification
    send :"send_#{platform}"
  end

  delegate :unregistered_devices, to: :apns

  private

  def send_ios
    apns.push(ios_notification)
    if ios_notification.sent?
      { status: :success }
    else
      Rollbar.error(ios_notification.error, notification: ios_notification)
      { status: :failure, error: ios_notification.error.inspect }
    end.merge unregistered_ios_devices
  end

  def send_android
    GcmServer.send_notification(@token, @payload)
  end

  def unregistered_ios_devices
    data = { unregistered_devices: unregistered_devices }
    Rollbar.info('APNS returned non-empty unregistered devices', data) unless data[:unregistered_devices].empty?
    data
  end
end
