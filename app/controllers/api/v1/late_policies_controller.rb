class Api::V1::LatePoliciesController < ApplicationController
    include AuthorizationHelper

    before_action :set_late_policy, only: %i[show edit update destroy]

    def action_allowed?
      case params[:action]
      when 'new', 'create', 'index'
        current_user_has_ta_privileges?
      when 'edit', 'update', 'destroy'
        current_user_has_ta_privileges? &&
        current_user.instructor_id == check_if_instructor
      else
        false
      end
    end

    def index
      @penalty_policies = LatePolicy.where(['instructor_id = ? OR private = 0', check_if_instructor])
      render json: @penalty_policies
    end

    def show
      render json: @penalty_policy
    end

    def new
      @penalty_policy = LatePolicy.new
      render json: @penalty_policy
    end

    def edit
      render json: @penalty_policy
    end

    def create
      valid_penalty, error_message = validate_input
      if error_message
        render json: { error: error_message }, status: :unprocessable_entity and return
      end

      if valid_penalty
        @late_policy = LatePolicy.new(late_policy_params)
        @late_policy.instructor_id = check_if_instructor
        if @late_policy.save
          render json: @late_policy, status: :created
        else
          render json: { error: 'The following error occurred while saving the late policy.' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Validation failed' }, status: :unprocessable_entity
      end
    end

    def update
      valid_penalty, error_message = @penalty_policy.duplicate_name_check(check_if_instructor, params[:id])

      if error_message
        render json: { error: error_message }, status: :unprocessable_entity and return
      end

      if valid_penalty
        if @penalty_policy.update(late_policy_params)
          LatePolicy.update_calculated_penalty_objects(@penalty_policy)
          render json: @penalty_policy, status: :ok
        else
          render json: { error: 'The following error occurred while updating the late policy.' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Validation failed' }, status: :unprocessable_entity
      end
    end

    def destroy
      if @penalty_policy.destroy
        head :no_content
      else
        render json: { error: 'This policy is in use and hence cannot be deleted.' }, status: :unprocessable_entity
      end
    end

    private

    def set_late_policy
      @penalty_policy = LatePolicy.find(params[:id])
    end

    def late_policy_params
      params.require(:late_policy).permit(:policy_name, :penalty_per_unit, :penalty_unit, :max_penalty)
    end

    def check_if_instructor
      late_policy.try(:instructor_id) || current_user.instructor_id
    end

    def late_policy
      @penalty_policy ||= @late_policy || LatePolicy.find(params[:id]) if params[:id]
    end

    def validate_input(is_update = false)
      max_penalty = params[:late_policy][:max_penalty].to_i
      penalty_per_unit = params[:late_policy][:penalty_per_unit].to_i

      valid_penalty, error_message = duplicate_name_check(is_update)
      prefix = is_update ? "Cannot edit the policy. " : ""

      if max_penalty < penalty_per_unit
        error_message = prefix + 'The maximum penalty cannot be less than penalty per unit.'
        valid_penalty = false
      end

      if penalty_per_unit < 0
        error_message = 'Penalty per unit cannot be negative.'
        valid_penalty = false
      end

      if max_penalty >= 100
        error_message = prefix + 'Maximum penalty cannot be greater than or equal to 100'
        valid_penalty = false
      end

      return valid_penalty, error_message
    end
  end
