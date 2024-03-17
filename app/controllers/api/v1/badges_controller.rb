class Api::V1::BadgesController < ApplicationController
  before_action :set_badge, only: %i[ show update destroy ]

  # GET /badges
  def index
    @badges = Badge.all

    render json: @badges
  end

  # GET /badges/1
  def show
    render json: @badge
  end

  # POST /badges
  def create
    @badge = Badge.new(badge_params)

    if @badge.save
      render json: @badge, status: :created, location: @badge
    else
      render json: @badge.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /badges/1
  def update
    if @badge.update(badge_params)
      render json: @badge
    else
      render json: @badge.errors, status: :unprocessable_entity
    end
  end

  # DELETE /badges/1
  def destroy
    @badge.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge
      @badge = Badge.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def badge_params
      params.require(:badge).permit(:name, :description, :image_name)
    end
end
