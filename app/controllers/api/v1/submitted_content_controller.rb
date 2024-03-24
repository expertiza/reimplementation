class Api::V1::SubmittedContentController < ApplicationController
    require 'mimemagic'
    require 'mimemagic/overlay'
  
    include AuthorizationHelper
  
    def action_allowed?
      case params[:action]
      when 'edit'
        current_user_has_student_privileges? &&
          are_needed_authorizations_present?(params[:id], 'reader', 'reviewer')
      when 'submit_file', 'submit_hyperlink'
        current_user_has_student_privileges? &&
          one_team_can_submit_work?
      else
        current_user_has_student_privileges?
      end
    end

    def controller_locale
      locale_for_student
    end

    def edit
      participant = AssignmentParticipant.find(params[:id])
      return unless current_user_id?(participant.user_id)

      assignment = participant.assignment
      # As we have to check if this participant has team or not
      # hence using team count for the check
      SignUpSheet.signup_team(assignment.id, participant.user_id, nil) if participant.team.nil?
      # @can_submit is the flag indicating if the user can submit or not in current stage
      @can_submit = !params.key?(:view)
      stage = assignment.current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
  end
end  
