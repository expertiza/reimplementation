class Api::V1::StudentQuizzesController < ApplicationController
  include AuthorizationHelper

  # Checks if the current user is authorized to perform the requested action.
  # For students, it verifies if they have the necessary roles for the 'index' action.
  # For TAs, it checks if they have TA privileges and are assigned to the current course.
  def action_allowed?
    if current_user_is_a? 'Student'
      if action_name.eql? 'index'
        are_needed_authorizations_present?(params[:id], 'reviewer', 'submitter')
      else
        true
      end
    else
      current_user_has_ta_privileges? && user_ta_for_current_course?
    end
  end

  # Fetches and lists all quiz response mappings for a specific participant in an assignment.
  def index
    @participant = AssignmentParticipant.find(params[:id])
    # Ensures the current user is authorized to view the participant's quiz mappings.
    return unless current_user_id?(@participant.user_id)

    @assignment = Assignment.find(@participant.parent_id)
    @quiz_mappings = ResponseMap.mappings_for_reviewer(@participant.id)
  end

  # Displays the questions and participant responses for a completed quiz
  def show_quiz_responses
    @response = Response.find(params[:response_id])
    @response_map = ResponseMap.find(params[:map_id])
    @questions = Question.where(questionnaire_id: @response_map.reviewed_object_id)
    @participant = AssignmentTeam.find(@response_map.reviewee_id).participants.first
    @quiz_score = @response.aggregate_questionnaire_score # Use the score calculated by Response model
  end

# Fetches quizzes for a given assignment that a reviewer has not yet started.
def fetch_available_quizzes_for_reviewer(assignment_id, reviewer_id)
  reviewer = Participant.find_by(user_id: reviewer_id, parent_id: assignment_id)
  return [] unless reviewer

  # Find quiz questionnaires created by teams in the assignment
  quiz_questionnaires = Questionnaire.where(instructor_id: Team.where(parent_id: assignment_id).pluck(:id))

  # Filter out quizzes already started by the reviewer
  available_quizzes = quiz_questionnaires.reject do |quiz|
    quiz.started_by?(reviewer)
  end

  available_quizzes
end

  # Submits the quiz response and calculates the score.
  def submit_quiz
    map = ResponseMap.find(params[:map_id])
    # Check if there is any response for this map_id. This is to prevent student from taking the same quiz twice.
    if map.response.empty?
      response = Response.create(map_id: params[:map_id], created_at: DateTime.current, updated_at: DateTime.current)
      if response.calculate_score(params)
        redirect_to controller: 'student_quizzes', action: 'show_finished_quiz', map_id: map.id
      else
        flash[:error] = 'Please answer every question.'
        redirect_to action: :fetch_available_quizzes_for_reviewer, assignment_id: params[:assignment_id], questionnaire_id: response.response_map.reviewed_object_id, map_id: map.id
      end
    else
      flash[:error] = 'You have already taken this quiz, below is the record of your responses.'
      redirect_to controller: 'student_quizzes', action: 'show_finished_quiz', map_id: map.id
    end
  end

  # Provides a list of quiz questionnaires for a given assignment.
  # This method is called when instructors click "view quiz questions" on the pop-up panel.
  def view_questions
    @assignment_id = params[:id]
    @quiz_questionnaires = []
    Team.where(parent_id: params[:id]).each do |quiz_creator|
      Questionnaire.where(instructor_id: quiz_creator.id).each do |questionnaire|
        @quiz_questionnaires.push questionnaire
      end
    end
  end
end
