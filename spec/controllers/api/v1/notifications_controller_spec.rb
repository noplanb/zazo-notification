require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  let(:service) { 'notification' }

  describe 'GET #index' do
    before do
      authenticate_with_http_digest do
        get :index
      end
    end

    specify do
      expect(response).to have_http_status(:ok)
    end

    specify do
      expect(json_response).to eq('data' =>
       [{ 'name' => 'sms',
          'description' => 'SMS notification via Twilio',
          'required_params' => %w(mobile_number body) }],
                                  'meta' => { 'total' => 1 })
    end
  end

  describe 'POST #create' do
    let(:params) { {} }

    describe 'unknown' do
      let(:id) { 'unknown' }

      before do
        authenticate_with_http_digest do
          post :create, { id: 'unknown' }.merge(params)
        end
      end

      specify do
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'sms' do
      let(:id) { 'sms' }
      let(:mobile_number) { '+380939523746' }
      let(:body) { 'Hello from Zazo!' }
      let(:instance) { Notification::Sms.new(params) }
      let(:twilio_ssid) { instance.twilio_ssid }
      let(:twilio_token) { instance.twilio_token }
      let(:from) { instance.from }
      let(:params) { { mobile_number: mobile_number, body: body } }

      context 'when body is missing' do
        let(:params) { { mobile_number: mobile_number } }

        before do
          authenticate_with_http_digest do
            post :create, { id: id }.merge(params)
          end
        end

        specify do
          expect(json_response).to eq(
            'status' => 'invalid',
            'errors' => {
              'body' => ["can't be blank"]
            },
            'original_response' => nil)
        end

        specify do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'on failure' do
        let(:mobile_number) { '+20227368296' }
        let(:code) { 21_614 }
        let(:message) { "To number: #{mobile_number}, is not a mobile number" }
        let(:original_response) do
          { 'code' => code,
            'message' => message,
            'more_info' => "https://www.twilio.com/docs/errors/#{code}",
            'status' => 400 }
        end

        before do
          allow_any_instance_of(Notification::Sms).to receive(:original_response).and_return(original_response)
          allow_any_instance_of(Notification::Sms).to receive(:create_message).and_raise(Twilio::REST::RequestError.new(message, code))
        end

        before do
          authenticate_with_http_digest do
            post :create, { id: id }.merge(params)
          end
        end

        specify do
          expect(json_response).to eq(
            'status' => 'failure',
            'errors' => {
              'twilio' => [message]
            },
            'original_response' => original_response)
        end

        specify do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'on success' do
        let(:original_response) do
          { 'sid' => 'SM9279a785961441499a81422737998152',
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
              'media' => "/2010-04-01/Accounts/#{twilio_ssid}/Messages/SM9279a785961441499a81422737998152/Media.json" } }
        end

        before do
          allow_any_instance_of(Notification::Sms).to receive(:original_response).and_return(original_response)
          allow_any_instance_of(Notification::Sms).to receive(:notify).and_return(true)
        end

        context 'response' do
          before do
            authenticate_with_http_digest do
              post :create, { id: id }.merge(params)
            end
          end

          specify do
            expect(json_response).to eq(
              'status' => 'success',
              'original_response' => original_response)
          end

          specify do
            expect(response).to have_http_status(:ok)
          end
        end

        context 'event notification', pending: 'FIXME: why not calls' do
          subject do
            authenticate_with_http_digest do
              post :create, { id: id }.merge(params)
            end
          end

          let(:event_params) do
            { initiator: 'service',
              initiator_id: service,
              target_id: mobile_number,
              data: {
                from: from,
                to: mobile_number,
                body: body
              },
              raw_params: params.merge(service: service) }
          end

          it_behaves_like 'event dispatchable', %w(notification sms)
        end
      end
    end
  end
end
