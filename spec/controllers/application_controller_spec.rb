require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:username) { 'notification' }
  
  describe 'GET #status' do
    before { get :status }

    specify do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #settings' do
    context 'when authenticated' do
      before do
        authenticate_with_http_digest do
          get :settings
        end
      end

      specify do
        expect(response).to have_http_status(:ok)
      end

      specify do
        expect(json_response).to be_a(Hash)
      end

      specify do
        expect(controller.current_service).to eq(username)
      end
    end

    context 'when not authenticated' do
      before { get :settings }
      specify do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
