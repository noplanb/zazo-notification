require 'rails_helper'

RSpec.shared_examples 'event dispatchable' do |event|
  it "EventDispatcher receives :emit with #{event.inspect}" do
    expect(EventDispatcher).to receive(:emit).with(event, event_params).and_call_original
    subject
  end

  it 'EventDispatcher.sqs_client receives :send_message', event_dispatcher: true do
    expect(EventDispatcher.sqs_client).to receive(:send_message)
    subject
  end
end
