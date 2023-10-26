class Api::V1::ParticipantsController < ApplicationController
  # GET /participants/index/:model/:id
  # params - model: "Course" or "Assignment", id: id of the corresponsing model object
  # returns a list of participants of an assignment or a course
  def index
    model_object = Object.const_get(params[:model]).find(params[:id].to_i)
    participants = model_object.participants

    render json: {
      "model_object": model_object,
      "participants": participants
    }, status: :ok
  rescue StandardError
    render json: { error: 'Invalid required parameters' }, status: :unprocessable_entity
  end

  # POST /participants/:model/:id
  # params - model: "Course" or "Assignment", id: id of the corresponsing model object
  # creates a participant in an assignment or a course
  def create
    user = User.find_by(name: params[:user][:name])
    if user.nil?
      render json: { error: "User #{params[:user][:name]} does not exist" }, status: :not_found
      return
    end

    model_object = Object.const_get(params[:model]).find(params[:id].to_i)

    queried_participant = model_object.participants.find_by(user_id: user.id)
    if queried_participant.present?
      render json: { error: "Participant #{params[:user][:name]} already exists for this #{params[:model]}" },
             status: :ok
      return
    end

    permissions = {
      can_submit: params[:participant][:can_submit],
      can_review: params[:participant][:can_review],
      can_take_quiz: params[:participant][:can_take_quiz]
    }

    if model_object.is_a?(Assignment)
      participant = model_object.add_participant(params[:user][:name], permissions)
    elsif model_object.is_a?(Course)
      participant = model_object.add_participant(params[:user][:name])
    end

    render json: { participant: }, status: :created
  end

  # PATCH /participants/update_handle/:id
  # params - id: id of the participant
  # updates the participant's handle in an assignment
  def update_handle
    participant = AssignmentParticipant.find(params[:id].to_i)
    if participant.handle == params[:participant][:handle]
      render json: { note: 'Handle already in use' }, status: :ok
      return
    end

    if participant.update(participant_params)
      render json: { participant: }, status: :ok
    else
      render json: { error: participant.errors }, status: :unprocessable_entity
    end
  end

  # PATCH /participants/update_authorization/:id
  # params - id: id of the participant
  # updates the permissions in an assignment or a course based on the participant role
  def update_authorization
    participant = Participant.find(params[:id].to_i)
    if participant.update(can_submit: params[:participant][:can_submit],
                          can_review: params[:participant][:can_review],
                          can_take_quiz: params[:participant][:can_take_quiz])
      render json: { participant: }, status: :ok
    else
      render json: { error: participant.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /participants/:id
  # params - id: id of the participant
  # destroys a participant from an assignment or a course
  def destroy
    participant = Participant.find(params[:id].to_i)
    begin
      participant.delete(false)
      render json: { message: "#{participant.user.name} was successfully removed as a participant" }, status: :ok
    rescue StandardError => e
      render json: { error: e }, status: :unprocessable_entity
    end
  end

  # GET /participants/inherit/:id
  # params - id: id of the assignment
  # copies existing participants from a course down to its assignment
  def inherit
    copy_participants_from_source_to_target(params[:id], :course_to_assignment)
  end

  # GET /participants/bequeath/:id
  # params - id: id of the assignment
  # copies existing participants from an assignment up to its course
  def bequeath
    copy_participants_from_source_to_target(params[:id], :assignment_to_course)
  end

  private

  # copies existing participants from source to target
  def copy_participants_from_source_to_target(_assignment_id, direction)
    assignment = Assignment.find(params[:id].to_i)
    course = assignment.course
    if course.nil?
      render json: { error: 'No course was found for this assignment' }, status: :unprocessable_entity
      return
    end

    source = direction == :course_to_assignment ? course : assignment
    if source.participants.empty?
      render json: { note: "No participants were found for this #{source.name}" }, status: :not_found
      return
    end

    target = direction == :course_to_assignment ? assignment : course

    any_participant_copied = source.participants.any? { |participant| participant.copy(target.id) }
    if any_participant_copied
      render json: { message: "The participants from #{source.name} were copied to #{target.name}" }, status: :created
    else
      render json: { note: "All of #{source.name} participants are already in #{target.name}" }, status: :ok
    end
  end

  def participant_params
    params.require(:participant).permit(:can_submit, :can_review, :user_id, :parent_id,
                                        :submitted_at, :permission_granted, :penalty_accumulated,
                                        :grade, :type, :handle, :time_stamp, :digital_signature,
                                        :duty, :can_take_quiz)
  end
end
