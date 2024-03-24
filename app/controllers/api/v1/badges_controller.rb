class Api::V1::BadgesController < ApplicationController
  before_action :set_badge, only: [:show, :edit, :update, :destroy]
  before_action :set_return_to, only: [:new]

  # GET /badges
  def index
    @badges = Badge.all
    render json: { badges: @badges }, status: :ok
  end

  def new
    @badge = Badge.new
    render json: { badge: @badge }, status: :ok
  end

  # GET /badges/1
  def show
    render json: { badge: @badge }, status: :ok
  end

  # POST /badges
  def create
    @badge = Badge.new(badge_params)
    handle_image_upload

    if @badge.save
      render json: { badge: @badge }, status: :created
    else
      render json: { errors: @badge.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /badges/1
  def update
    handle_image_upload
    if @badge.update(badge_params)
      render json: { badge: @badge }, status: :ok
    else
      render json: { errors: @badge.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /badges/1
  def destroy
    @badge.destroy
    render json: { message: "Badge was successfully destroyed." }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge
      @badge = Badge.find(params[:id])
    end

    def set_return_to
      session[:return_to] ||= request.referer
    end

    # Only allow a list of trusted parameters through.
    def badge_params
      params.require(:badge).permit(:name, :description, :image_name)
    end

    def handle_image_upload
      image_file = params[:badge][:image_file]
      if image_file
        File.open(Rails.root.join('app', 'assets', 'images', 'badges', image_file.original_filename), 'wb') do |file|
          file.write(image_file.read)
        end
        @badge.image_name = image_file.original_filename
      else
        @badge.image_name = ''
      end
    end
end
