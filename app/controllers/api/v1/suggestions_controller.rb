# https://wiki.expertiza.ncsu.edu/index.php?title=CSC/ECE_517_Fall_2024_-_E2477._Reimplement_suggestion_controller.rb_(Design_Document)
class Api::V1::SuggestionsController < ApplicationController
  include AuthorizationHelper

  before_action :action_allowed?

  # Determine whether the current request is allowed
  def action_allowed?
    case params[:action]
    when 'create'
      # Create has no special permissions
      return true
    when 'show', 'update'
      # When showing or updating a suggestion, a student that owns the suggestions passes
      suggestion = Suggestion.find(params[:id])
      return true if suggestion.user_id == @current_user.id
    end
    # A TA or above always passes
    # TODO: Check if user is TA or above in the same course that the suggestion is
    unless AuthorizationHelper.current_user_has_ta_privileges?
      render json: { error: 'Authorization failed' }, status: :forbidden
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: e, status: :not_found # 404
  end

  # Comment on a suggestion.
  # A new SuggestionComment record is made.
  def add_comment
    params.require(%i[comment id])
    Suggestion.find(params[:id])
    render json: SuggestionComment.create!(
      comment: params[:comment],
      suggestion_id: params[:id],
      user_id: @current_user.id
    ), status: :created # 201
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  rescue ActiveRecord::RecordNotFound => e
    render json: e, status: :not_found # 404
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity # 422
  end

  # Approve a suggestion, even if it was previously rejected.
  def approve
    params.require(:id)
    @suggestion = Suggestion.find(params[:id])
    # Only go through the approval process if the suggestion isn't already approved.
    unless @suggestion.status == 'Approved'
      # Since this process updates multiple records at once, wrap them in
      #   a transaction so that either all of them succeed, or none of them.
      Suggestion.transaction do
        # The approval process is:
        # 1. Mark the suggestion as approved
        # 2. Create a new topic from the suggestion
        # 3. Sign the suggester's team up (create new team if necessary)
        # 4. Send the topic approved message
        @suggestion.update_attribute('status', 'Approved')
        create_topic_from_suggestion!
        # If a suggestion is anonymous, the suggester is
        #  unknown and thus steps 3 and 4 can't be taken.
        unless @suggestion.user_id.nil?
          @suggester = User.find(@suggestion.user_id)
          sign_team_up!
          send_notice_of_approval
        end
      end
    end
    render json: @suggestion, status: :ok # 200
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  rescue ActiveRecord::RecordNotFound => e
    render json: e, status: :not_found # 404
  rescue ActiveRecord::RecordInvalid => e
    if e.record
      render json: e.record.errors, status: :unprocessable_entity # 422
    else
      render json: { error: 'Unable to approve suggestion due to an invalid record.' }, status: :unprocessable_entity # 422
    end
  end

  # A new Suggestion record is made.
  def create
    params.require(%i[anonymous assignment_id auto_signup description title])
    render json: Suggestion.create!(
      assignment_id: params[:assignment_id],
      auto_signup: params[:auto_signup],
      description: params[:description],
      status: 'Initialized',
      title: params[:title],
      # Anonymous suggestions are allowed by nulling user_id.
      user_id: params[:anonymous] ? nil : @current_user.id
    ), status: :created # 201
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity # 422
  end

  # Delete a suggestion from the records.
  def destroy
    params.require(:id)
    Suggestion.find(params[:id]).destroy!
    render json: {}, status: :no_content # 204
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  rescue ActiveRecord::RecordNotFound => e
    render json: e, status: :not_found # 404
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: e, status: :unprocessable_entity # 422
  end

  # Get a list of all Suggestion records associated with a particular assignment.
  def index
    params.require(:id)
    render json: Suggestion.where(assignment_id: params[:id]), status: :ok # 200
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  end

  # Reject a suggestion unless it was already approved.
  def reject
    params.require(:id)
    @suggestion = Suggestion.find(params[:id])
    # Since the approval process makes changes to many records,
    #   rejecting a previously approved suggestion is not possible.
    if @suggestion.status == 'Approved'
      render json: { error: 'Suggestion has already been approved.' }, status: :unprocessable_entity # 422
      return
    elsif @suggestion.status == 'Initialized'
      # The rejection process is:
      # 1. Mark the suggestion as rejected
      # 2. Send the topic rejected message
      @suggestion.update_attribute('status', 'Rejected')
      send_notice_of_rejection if @suggestion.user_id
    end
    render json: @suggestion, status: :ok # 200
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  rescue ActiveRecord::RecordNotFound => e
    render json: e, status: :not_found # 404
  end

  # Get a single Suggestion record.
  def show
    params.require(:id)
    @suggestion = Suggestion.find(params[:id])
    render json: {
      comments: SuggestionComment.where(suggestion_id: params[:id]),
      suggestion: @suggestion
    }, status: :ok # 200
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  rescue ActiveRecord::RecordNotFound => e
    render json: e, status: :not_found # 404
  end

  # Change the details of a Suggestion.
  def update
    params.require(:id)
    @suggestion = Suggestion.find(params[:id])
    # Only title, description, and signup preference can be changed.
    @suggestion.update!(params.permit(:title, :description, :auto_signup))
    render json: @suggestion, status: :ok # 200
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} is missing" }, status: :unprocessable_entity # 422
  rescue ActiveRecord::RecordNotFound => e
    render json: e, status: :not_found # 404
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity # 422
  end

  private

  def create_topic_from_suggestion!
    # Convert a suggestion into a fully fledged topic.
    @signuptopic = SignUpTopic.create!(
      assignment_id: @suggestion.assignment_id,
      max_choosers: 1,
      topic_identifier: "S#{Suggestion.where(assignment_id: @suggestion.assignment_id).count}",
      topic_name: @suggestion.title
    )
  end

  def send_notice_of_approval
    # Email the suggester and CC the suggester's teammates that the suggestion was approved
    Mailer.send_topic_approved_email(
      cc: User.joins(:teams_users).where(teams_users: { team_id: @team.id }).where.not(id: @suggester.id).map(&:email),
      subject: "Suggested topic '#{@suggestion.title}' has been approved",
      suggester: @suggester,
      topic_name: @suggestion.title
    )
  end

  def send_notice_of_rejection
    # Email the suggester that the suggestion was rejected
    Mailer.send_topic_rejected_email(
      subject: "Suggested topic '#{@suggestion.title}' has been rejected",
      suggester: User.find(@suggestion.user_id),
      topic_name: @suggestion.title
    )
  end

  def sign_team_up!
    return unless @suggestion.auto_signup == true

    # Find the suggester's team which is signed up to the topic's assignment.
    @team = Team.where(assignment_id: @signuptopic.assignment_id).joins(:teams_users)
                .where(teams_users: { user_id: @suggester.id }).first
    # Create the team if necessary.
    if @team.nil?
      @team = Team.create!(assignment_id: @signuptopic.assignment_id)
      TeamsUser.create!(team_id: @team.id, user_id: @suggester.id)
    end
    # If the suggester's team has no assignment, then clear its
    #   waitlist and sign it up to the newly created topic.
    unless SignedUpTeam.exists?(team_id: @team.id, is_waitlisted: false)
      SignedUpTeam.where(team_id: @team.id, is_waitlisted: true).destroy_all
      SignedUpTeam.create!(sign_up_topic_id: @signuptopic.id, team_id: @team.id, is_waitlisted: false)
    end
    # Since the suggester's team is signed up to the topic, make it private
    #   to the suggester so no other teams will attempt to sign up to it.
    @signuptopic.update_attribute(:private_to, @suggester.id)
  end
end
