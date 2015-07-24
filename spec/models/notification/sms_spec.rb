require 'rails_helper'

RSpec.describe Notification::Sms, type: :model do
  let(:mobile_number) { '+380939523746' }
  let(:body) { 'Hello from Zazo!' }
  let(:params) { { mobile_number: mobile_number, body: body } }
  let(:instance) { described_class.new(params) }
  let(:twilio_ssid) { instance.twilio_ssid }
  let(:twilio_token) { instance.twilio_token }
  let(:from) { instance.from }

  describe '#notify', pending: 'FIXME: vcr' do
    subject { instance.notify }

    context 'on success' do
      around do |example|
        VCR.use_cassette('twilio/message_with_success', erb: {
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
          status: 'success', original_response: {
            'sid' => 'SM272eb583ba9f40859abd816e97958bbf',
            'date_created' => 'Thu, 19 Mar 2015 22:52:19 +0000',
            'date_updated' => 'Thu, 19 Mar 2015 22:52:19 +0000',
            'date_sent' => nil,
            'account_sid' => twilio_ssid,
            'to' => mobile_number,
            'from' => from,
            'body' => body,
            'status' => 'queued',
            'num_segments' => '1',
            'num_media' => '0',
            'direction' => 'outbound-api', 'api_version' => '2010-04-01',
            'price' => nil, 'price_unit' => 'USD', 'error_code' => nil,
            'error_message' => nil,
            'uri' => "/2010-04-01/Accounts/#{twilio_ssid}/Messages/SM272eb583ba9f40859abd816e97958bbf.json",
            'subresource_uris' => {
              'media' => "/2010-04-01/Accounts/#{twilio_ssid}/Messages/SM272eb583ba9f40859abd816e97958bbf/Media.json"
            }
          })
      end
    end

    context 'on invalid number' do
      let(:mobile_number) { '+20227368296' }
      let(:code) { 21_614 }
      let(:message) { "'To' number is not a valid mobile number" }

      around do |example|
        VCR.use_cassette('twilio/message_with_error', erb: {
          twilio_ssid: twilio_ssid,
          twilio_token: twilio_token,
          from: from,
          to: mobile_number,
          body: body }.merge(code: code, message: message)) do
          example.run
        end
      end

      specify do
        is_expected.to eq(status: 'failed',
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
