class Notification::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  attr_reader :params, :service

  REQUIRED_PARAMS = []

  define_model_callbacks :initialize

  def self.required_params
    self::REQUIRED_PARAMS
  end

  def self.description
    "Write description in `#{self}.description` method"
  end

  def self.notification_name
    name.demodulize.underscore
  end

  def self.to_hash
    { name: notification_name,
      description: description,
      required_params: required_params }
  end

  def self.to_param
    notification_name
  end

  def initialize(params = {})
    run_callbacks :initialize do
      @params = params.symbolize_keys
    end
  end

  def notify
    send_event if do_notify
  end

  def original_response
  end

  protected

  def do_notify
  end

  def event_data
  end

  def event
    { initiator: 'service',
      initiator_id: service,
      data: event_data,
      raw_params: params }
  end

  def send_event
    EventDispatcher.emit(['notification', self.class.notification_name], event)
  end

  def log_success
    Rails.logger.info "#{self.class.notification_name}: #{params}"
  end

  def log_error(error)
    Rails.logger.error "#{self.class.notification_name}: #{error.inspect}"
  end

  def notify_rollbar(error)
    Rollbar.warning(error)
  end

  def set_attributes
    @service = params[:service]
  end
  after_initialize :set_attributes

end
