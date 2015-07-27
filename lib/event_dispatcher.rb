module EventDispatcher
  @send_message_enabled = true

  def self.queue_url
    Figaro.env.sqs_queue_url
  end

  def self.sqs_client
    @sqs_client ||= Aws::SQS::Client.new
  end

  def self.enable_send_message!
    Rails.logger.info "[#{self}] Enabling #{self}"
    @send_message_enabled = true
  end

  def self.disable_send_message!
    Rails.logger.info "[#{self}] Disabling #{self}"
    @send_message_enabled = false
  end

  def self.send_message_enabled?
    @send_message_enabled
  end

  def self.with_state(state)
    original = send_message_enabled?
    Rails.logger.debug "[#{self}] #{original} => #{state}"
    @send_message_enabled = state
    yield if block_given?
    Rails.logger.debug "[#{self}] #{state} => #{original}"
    @send_message_enabled = original
  end

  def self.build_message(name, params = {})
    name = name.split(':') if name.is_a?(String)
    params.reverse_merge(
      name: name,
      triggered_by: 'zazo:api',
      triggered_at: DateTime.now.utc)
  end

  def self.emit(name, params = {})
    message = build_message(name, params)
    Rails.logger.info "[#{self}] Attemt to sent message to SQS queue #{queue_url}: #{message}"
    if send_message_enabled?
      sqs_client.send_message(queue_url: queue_url, message_body: message.to_json)
    else
      Rails.logger.info "[#{self}] Message not sent to SQS because #{self} is disabled"
      {}
    end
  end
end
