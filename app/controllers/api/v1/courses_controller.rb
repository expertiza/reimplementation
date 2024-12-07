class Api::V1::CoursesController < ApplicationController
  before_action :set_course, only: %i[ show update destroy add_ta view_tas remove_ta copy ]
  rescue_from ActiveRecord::RecordNotFound, with: :course_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  # GET /courses
  # List all the courses
  def index
    courses = Course.all
    render json: courses, status: :ok
  end

  # GET /courses/1
  # Get a course
  def show
    render json: @course, status: :ok
  end

  # POST /courses
  # Create a course
  def create
    course = Course.new(course_params)
    if course.save
      render json: course, status: :created
    else
      render json: course.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1
  # Update a course
  def update
    if @course.update(course_params)
      render json: @course, status: :ok
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  # DELETE /courses/1
  # Delete a course
  def destroy
    @course.destroy
    render json: { message: "Course with id #{params[:id]}, deleted" }, status: :no_content
  end

  # Adds a Teaching Assistant to the course
  def add_ta
    user_id = params[:ta_id] # Use user_id from the request
    print(user_id)
    user = User.find_by(id: user_id)
    
    course_id = params[:id]
    @course = Course.find_by(id: course_id)
  
    if user.nil?
      render json: { status: "error", message: "The user with id #{user_id} does not exist" }, status: :not_found
      return
    end
  
    result = @course.add_ta(user)
    if result[:success]
      render json: result[:data], status: :created
    else
      render json: { status: "error", message: result[:message] }, status: :bad_request
    end
  end

  # Displays all Teaching Assistants for the course
  def view_tas
    teaching_assistants = @course.tas
    render json: teaching_assistants, status: :ok
  end

  # Removes Teaching Assistant from the course
  def remove_ta
    result = @course.remove_ta(params[:ta_id])
    if result[:success]
      render json: { message: "The TA #{result[:ta_name]} has been removed." }, status: :ok
    else
      render json: { status: "error", message: result[:message] }, status: :not_found
    end
  end

  # Creates a copy of the course
  def copy
    # existing_course = Course.find(params[:id])
    success = @course.copy_course
    if success
      render json: { message: "The course #{@course.name} has been successfully copied" }, status: :ok
    else
      render json: { message: "The course was not able to be copied" }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def course_params
    params.require(:course).permit(:name, :directory_path, :info, :private, :instructor_id, :institution_id)
  end

  def course_not_found
    render json: { error: "Course with id #{params[:id]} not found" }, status: :not_found
  end

  def parameter_missing
    render json: { error: "Parameter missing" }, status: :unprocessable_entity
  end
end
