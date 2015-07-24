require 'rails_helper'

RSpec.describe Notification::Sms, type: :model do
  let(:mobile_number) { '+380939523746' }
  let(:body) { 'Hello from Zazo!' }
  let(:params) { { mobile_number: mobile_number, body: body } }
  let(:instance) { described_class.new(params) }
  let(:twilio_ssid) { instance.twilio_ssid }
  let(:twilio_token) { instance.twilio_token }
  let(:from) { instance.from }

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

      specify do
        is_expected.to eq(
          status: :success,
          original_response: {
            'sid' => 'SM9279a785961441499a81422737998152',
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
              'media' => "/2010-04-01/Accounts/#{twilio_ssid}/Messages/SM9279a785961441499a81422737998152/Media.json" } })
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

      specify do
        is_expected.to eq(status: :failed,
                          errors: [
                            'Twilio error' => message
                          ],
                          original_response: {
                            'code' => code,
                            'message' => message,
                            'more_info' => "https://www.twilio.com/docs/errors/#{code}", 'status' => 400
                          })
      end
    end
  end
end
