class Api::V1::DutiesController < ApplicationController
  before_action :set_duty, only: %i[ show update destroy ]

  # GET /duties
  def index
    @duties = Duty.all

    render json: @duties
  end

  # GET /duties/1
  def show
    render json: @duty
  end

  # POST /duties
  def create
    @duty = Duty.new(duty_params)

    if @duty.save
      render json: @duty, status: :created, location: @duty
    else
      render json: @duty.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /duties/1
  def update
    if @duty.update(duty_params)
      render json: @duty
    else
      render json: @duty.errors, status: :unprocessable_entity
    end
  end

  # DELETE /duties/1
  def destroy
    @duty.destroy
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_duty
      @duty = Duty.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def duty_params
      params.require(:duty).permit(:name, :max_members_for_duty, :assignment_id)
    end
end
