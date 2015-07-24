module BasicAuthHelpers
  def authenticate_with_http_basic(username = nil, password = nil)
    username ||= 'notification'
    password ||= Credentials.services.notification
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end

RSpec.configure do |config|
  config.include BasicAuthHelpers, type: :controller
end
