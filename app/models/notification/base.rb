class Notification::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  attr_reader :params

  define_model_callbacks :initialize

  def self.notification_name
    name.demodulize.underscore
  end

  def self.required_params
    []
  end

  def self.to_hash
    { name: notification_name, required_params: required_params }
  end

  def initialize(params = {})
    run_callbacks :initialize do
      @params = params.symbolize_keys
    end
  end

  def notify
  end
end
