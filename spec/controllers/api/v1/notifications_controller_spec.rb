require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  let(:username) { 'notification' }
  let(:password) { Credentials.services.notification }

  describe 'GET #index' do
    before do
      authenticate_with_http_digest(username, password) do
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
end
