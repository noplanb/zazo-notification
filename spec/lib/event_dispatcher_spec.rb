require 'rails_helper'

RSpec.describe EventDispatcher do
  describe '.emit', event_dispatcher: true do
    let(:name) { %w(event_dispatcher test) }
    let(:params) do
      { initiator: 'user',
        initiator_id: '1' }
    end
    subject { described_class.emit(name, params) }
    around do |example|
      VCR.use_cassette('sqs_send_message', erb: {
                         queue_url: described_class.queue_url,
                         region: described_class.sqs_client.config.region,
                         access_key: described_class.sqs_client.config.credentials.access_key_id }) do
        example.run
      end
    end

    it { is_expected.to be_a(Seahorse::Client::Response) }

    context 'when name is string' do
      let(:name) { 'zazo:test' }
      it { is_expected.to be_a(Seahorse::Client::Response) }
    end
  end

  describe '.build_message' do
    let(:name) { %w(zazo test) }
    let(:params) { {} }
    let(:triggered_at) { DateTime.now.utc }
    subject { described_class.build_message(name, params) }

    specify do
      Timecop.freeze(triggered_at) do
        is_expected.to eq(name: %w(zazo test),
                          triggered_by: 'zazo:api',
                          triggered_at: DateTime.now.utc)
      end
    end

    context 'when name is string' do
      let(:name) { 'zazo:test' }
      specify do
        Timecop.freeze(triggered_at) do
          is_expected.to eq(name: %w(zazo test),
                            triggered_by: 'zazo:api',
                            triggered_at: DateTime.now.utc)
        end
      end
    end
  end

  describe '.disable_send_message!', event_dispatcher: true do
    subject { described_class.disable_send_message! }
    specify do
      expect { subject }.to change { described_class.send_message_enabled? }.from(true).to(false)
    end
  end

  describe '.enable_send_message!', event_dispatcher: false do
    subject { described_class.enable_send_message! }
    specify do
      expect { subject }.to change { described_class.send_message_enabled? }.from(false).to(true)
    end
  end

  describe '.with_state' do
    context 'true' do
      specify 'send_message_enabled should be truthy' do
        described_class.with_state(true) { expect(described_class.send_message_enabled?).to be_truthy }
      end
    end

    context 'false' do
      specify 'send_message_enabled should be falsey' do
        described_class.with_state(false) { expect(described_class.send_message_enabled?).to be_falsey }
      end
    end
  end
end
