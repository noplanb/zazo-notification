class Api::V1::NotificationsController < ApplicationController
  before_action :find_notification, only: [:create]
  before_action :check_notification_is_valid, only: [:create]

  def index
    @notifications = Notification.all
    render json: { data: @notifications, meta: { total: @notifications.size } }
  end

  def create
    @notification.notify
    if @notification.valid?
      render json: { status: :success,
                     original_response: @notification.original_response }
    else
      render status: :bad_request, json: { status: :failure,
                                           errors: @notification.errors,
                                           original_response: @notification.original_response }
    end
  end

  protected

  def notification_params
    params.except('controller', 'action', 'id')
  end

  def find_notification
    @notification = Notification.find(params[:id]).new(notification_params.merge(client: current_client))
  rescue Notification::UnknownNotification => error
    render status: :not_found, json: { status: :not_found,
                                       errors: { error.class.name => error.message } }
  end

  def check_notification_is_valid
    if @notification.invalid?
      render status: :unprocessable_entity,
             json: { status: :invalid,
                     errors: @notification.errors,
                     original_response: nil }
    end
  end
end
