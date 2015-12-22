class Notification::Base
  class Params < Hash
    include Hashie::Extensions::IndifferentAccess
  end

  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  attr_reader :params, :client

  REQUIRED_PARAMS = []

  define_model_callbacks :initialize
  after_initialize :set_attributes

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
      @params = wrap_params params
    end
  end

  def notify
    do_notify
    log_success
    send_event
  rescue StandardError => error
    handle_error(error)
  end

  def original_response
  end

  def valid?(context = nil)
    errors.empty? && super(context)
  end

  def do_notify
  end

  def event_data
  end

  def event
    { initiator: 'client',
      initiator_id: client,
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

  protected

  def handle_error(error)
    log_error(error)
    notify_rollbar(error)
    errors.add(error.class.name, error.message)
  end

  def set_attributes
    @client = params[:client]
  end

  def wrap_params(params)
    Params[params]
  end
end
