class Api::V1::NotificationsController < ApplicationController
  include AuthorizationHelper

  before_action :set_notification, only: %i[show update destroy]

  # GET /notifications
  def index
    if current_user_has_instructor_privileges? || current_user_has_ta_privileges?
      @notifications = Notification.where(user_id: current_user.id)
    elsif current_user_has_student_privileges?
      course_names = current_user.courses.pluck(:name)
      @notifications = Notification.where(course_name: course_names, active_flag: true)
    else
      render json: { error: 'Access denied' }, status: :forbidden
      return
    end

    render json: @notifications
  end

  # GET /notifications/:id
  def show
    if notification_accessible?(@notification)
      render json: @notification
    else
      render json: { error: 'You do not have access to this notification.' }, status: :forbidden
    end
  end

  # POST /notifications
  def create
    # Check if the current user has sufficient privileges
    unless current_user_has_instructor_privileges? || current_user_has_ta_privileges?
      render json: { error: 'You are not authorized to create notifications.' }, status: :forbidden
      return
    end
  
    @notification = Notification.new(notification_params)
    @notification.user_id = current_user.id
  
    if @notification.save
      render json: @notification, status: :created
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /notifications/:id
  def update
    # Check if the current user has sufficient privileges
    unless current_user_has_instructor_privileges? || current_user_has_ta_privileges?
      render json: { error: 'You are not authorized to update notifications.' }, status: :forbidden
      return
    end
  
    if @notification.update(notification_params)
      render json: @notification, status: :ok
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end
  

  # DELETE /notifications/:id
  def destroy
    # Check if the current user has sufficient privileges
    unless current_user_has_instructor_privileges? || current_user_has_ta_privileges?
      render json: { error: 'You are not authorized to delete notifications.' }, status: :forbidden
      return
    end
  
    if @notification.destroy
      render json: { message: 'Notification deleted successfully.' }, status: :ok
    else
      render json: { error: 'Failed to delete the notification.' }, status: :unprocessable_entity
    end
  end
  

  # PATCH /notifications/:id/toggle_active
  def toggle_notification_visibility
    if notification_accessible?(@notification)
      @notification.update(active_flag: !@notification.active_flag)
      render json: { message: 'Notification visibility toggled successfully.', notification: @notification }, status: :ok
    else
      render json: { error: 'You are not authorized to toggle this notification.' }, status: :forbidden
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Notification not found.' }, status: :not_found
  end

  # Define strong parameters for notification creation/update
  def notification_params
    params.require(:notification).permit(:course_name, :subject, :description, :expiration_date, :active_flag)
  end

  # Helper method to check if a notification is accessible to the current user
  def notification_accessible?(notification)
    # Instructors and TAs can access their own notifications
    return true if notification.user_id == current_user.id

    # Students can access notifications for their courses
    return true if current_user_has_student_privileges? &&
                   current_user.courses.exists?(name: notification.course_name)

    false
  end
end
