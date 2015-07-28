require 'rails_helper'

RSpec.describe Notification::Sms, type: :model do
  let(:mobile_number) { '+380939523746' }
  let(:body) { 'Hello from Zazo!' }
  let(:service) { 'notification' }
  let(:params) { { service: service, mobile_number: mobile_number, body: body } }
  let(:instance) { described_class.new(params) }
  let(:twilio_ssid) { instance.twilio_ssid }
  let(:twilio_token) { instance.twilio_token }
  let(:from) { instance.from }

  describe '.required_params' do
    subject { described_class.required_params }
    it { is_expected.to eq(%w(mobile_number body)) }
  end

  describe '.description' do
    subject { described_class.description }
    it { is_expected.to eq('SMS notification via Twilio') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:mobile_number) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:from) }
  end

  describe '#notify' do
    subject { instance.notify }

    context 'on success' do
      around do |example|
        VCR.use_cassette('twilio/message/success', erb: {
                           twilio_ssid: twilio_ssid,
                           twilio_token: twilio_token,
                           from: from,
                           to: mobile_number,
                           body: body }) do
          example.run
        end
      end

      context 'errors' do
        before { instance.notify }
        subject { instance.errors }

        specify do
          is_expected.to be_empty
        end
      end

      context '#valid?' do
        subject { instance.valid? }
        it { is_expected.to be true }
      end

      context 'original_response' do
        before { instance.notify }
        subject { instance.original_response }

        specify do
          is_expected.to eq('sid' => 'SM9279a785961441499a81422737998152',
                            'date_created' => 'Fri, 24 Jul 2015 11:50:24 +0000',
                            'date_updated' => 'Fri, 24 Jul 2015 11:50:24 +0000',
                            'date_sent' => nil,
                            'account_sid' => twilio_ssid,
                            'to' => mobile_number,
                            'from' => from,
                            'body' => body,
                            'status' => 'queued',
                            'num_segments' => '1',
                            'num_media' => '0',
                            'direction' => 'outbound-api',
                            'api_version' => '2010-04-01',
                            'price' => nil,
                            'price_unit' => 'USD',
                            'error_code' => nil,
                            'error_message' => nil,
                            'uri' => "/2010-04-01/Accounts/#{twilio_ssid}/Messages/SM9279a785961441499a81422737998152.json",
                            'subresource_uris' => {
                              'media' => "/2010-04-01/Accounts/#{twilio_ssid}/Messages/SM9279a785961441499a81422737998152/Media.json" })
        end
      end

      context 'event notification' do
        let(:event_params) do
          { initiator: 'service',
            initiator_id: 'notification',
            data: {
              from: from,
              to: mobile_number,
              body: body
            },
            raw_params: params }
        end

        it_behaves_like 'event dispatchable', %w(notification sms)
      end
    end

    context 'on invalid number' do
      let(:mobile_number) { '+20227368296' }
      let(:code) { 21_614 }
      let(:message) { "To number: #{mobile_number}, is not a mobile number" }

      around do |example|
        VCR.use_cassette('twilio/message/error', erb: {
          twilio_ssid: twilio_ssid,
          twilio_token: twilio_token,
          from: from,
          to: mobile_number,
          body: body }.merge(code: code, message: message)) do
          example.run
        end
      end

      before { instance.notify }
      subject { instance }

      it { is_expected.to be_invalid }

      context 'original_response' do
        subject { instance.original_response }

        specify do
          is_expected.to eq('code' => code,
                            'message' => message,
                            'more_info' => "https://www.twilio.com/docs/errors/#{code}",
                            'status' => 400)
        end
      end

      context 'errors.messages' do
        subject { instance.errors.messages }

        specify do
          is_expected.to eq(:'Twilio::REST::RequestError' => [message])
        end
      end
    end
  end
end
