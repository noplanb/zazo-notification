class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Digest::ControllerMethods

  REALM = Settings.app_name
  attr_accessor :current_client

  before_action :authenticate, except: [:status]

  def status
    render json: Settings.to_hash.slice('app_name', 'version', 'authentication_method')
  end

  def settings
    render json: Settings.to_hash
  end

  protected

  def authentication_method
    Settings.authentication_method || :digest
  end

  def authenticate
    Rails.logger.debug "Trying authenticate with #{authentication_method.inspect}"
    send("authenticate_with_#{authentication_method}")
  end

  def authenticate_with_basic
    authenticate_or_request_with_http_basic(REALM) do |username, password|
      Rails.logger.info "Authenticating client: #{username}"
      self.current_client = username
      Credentials.password_for(username) == password
    end
  end

  def request_http_basic_authentication(realm = REALM)
    headers['WWW-Authenticate'] = %(Basic realm="#{realm.gsub(/"/, '')}")
    render json: { status: :unauthorized }, status: :unauthorized
  end

  def authenticate_with_digest
    authenticate_or_request_with_http_digest(REALM) do |username|
      Rails.logger.info "Authenticating client: #{username}"
      self.current_client = username
      Credentials.password_for(username)
    end
  end

  def request_http_digest_authentication(realm = REALM, _message = nil)
    super(realm, { status: :unauthorized }.to_json)
  end
end
