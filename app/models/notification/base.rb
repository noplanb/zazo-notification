class Notification::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  attr_reader :params

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
  end
end
