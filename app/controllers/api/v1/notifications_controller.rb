class Api::V1::NotificationsController < ApplicationController
  def index
    Rails.logger.ap request.env
    @notifications = Notification.all
    render json: { data: @notifications, meta: { total: @notifications.size } }
  end

  def create
    render json: {}
  end
end
