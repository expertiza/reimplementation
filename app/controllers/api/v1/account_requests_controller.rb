class Api::V1::AccountRequestsController < ApplicationController

  # GET /account_requests/pending
  def pending_request
    @account_requests = AccountRequest.where(status: 'Under Review').order('created_at DESC')
    render json: @account_requests, status: :ok
  end

  # GET /account_requests/processed
  def processed_request
    @account_requests = AccountRequest.where.not(status: 'Under Review').order('updated_at DESC')
    render json: @account_requests, status: :ok
  end

  # POST /account_requests
  def create
    @account_request = AccountRequest.new(account_request_params)
    if @account_request.save
      render json: @account_request, status: :created
    else
      render json: @account_request.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :parameter_missing
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /account_requests/:id
  def show
    @account_request = AccountRequest.find(params[:id])
    render json: @account_request, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  # PATCH/PUT /account_requests/:id
  def update
    @account_request = AccountRequest.find(params[:id])
    @account_request.update(account_request_params)
    if @account_request.status == 'Approved'
      create_approved_user
    else
      render json: @account_request, status: :ok
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # DELETE /account_requests/:id
  def destroy
    @account_request = AccountRequest.find(params[:id])
    @account_request.destroy
    render json: { message: 'Account Request deleted' }, status: :no_content
  rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
  end

  private

  # Only allow a list of trusted parameters through.
  def account_request_params
    if params[:account_request][:status].nil?
      params[:account_request][:status] = 'Under Review'
    elsif !['Approved', 'Rejected'].include?(params[:account_request][:status])
      raise StandardError, 'Status can only be Approved or Rejected'
    end
    params.require(:account_request).permit(:name, :FullName, :email, :status, :introduction, :role_id, :institution_id)
  end

  # Create a new user if account request is approved
  def create_approved_user
    @new_user = User.new(name: @account_request.name, role_id: @account_request.role_id, institution_id: @account_request.institution_id, fullname: @account_request.FullName, email: @account_request.email, password: 'password')
    if @new_user.save
      render json: { success: 'Account Request Approved and User successfully created.', user: @new_user}, status: :ok
    else
      render json: @new_user.errors, status: :unprocessable_entity
    end
  end
end
