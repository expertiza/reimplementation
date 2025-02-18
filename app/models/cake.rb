class Cake < ScoredQuestion
  include ActionView::Helpers
  validates :size, presence: true

  # Retrieves and calculates the total score for a specific question.
  def running_total(review_type, question_id, participant_id, assignment_id, reviewee_id)
    team_id = Team.joins(teams_users: :participant)
                  .where('participants.id = ? AND teams.parent_id = ?', participant_id, assignment_id)
                  .pluck(:id)
                  .first
    return 0 unless team_id

    if review_type == 'TeammateReviewResponseMap'
      answers = Participant.joins(user: :teams_users)
                           .where('teams_users.team_id = ? AND participants.parent_id = ?', team_id, assignment_id)
                           .pluck(:id)
                           .flat_map do |team_member_id|
        Answer.joins(response: :response_map)
              .where("response_maps.reviewee_id = ? AND response_maps.reviewed_object_id = ?
                      AND response_maps.reviewer_id = ? AND answers.question_id = ?
                      AND response_maps.reviewee_id != ? AND answers.answer IS NOT NULL",
                      team_member_id, assignment_id, participant_id, question_id, reviewee_id)
      end
      answers.compact.sum(&:answer)
    else
      0
    end
  end

  # The score a user gave to a specific question.
  def score_given_by_user(participant_id, question_id, assignment_id, reviewee_id)
    Answer.joins(response: :response_map)
          .where("response_maps.reviewer_id = ? AND response_maps.reviewee_id = ? AND response_maps.reviewed_object_id = ? AND answers.question_id = ?",
                 participant_id, reviewee_id, assignment_id, question_id)
          .pluck(:answer)
          .first || 0
  end

  # The score a user has left to give for a question.
  def score_remaining_for_user(review_type, question_id, participant_id, assignment_id, reviewee_id)
    total_score = running_total(review_type, question_id, participant_id, assignment_id, reviewee_id)
    remaining_score = 100 - total_score
    remaining_score.negative? ? 0 : remaining_score
  end
end
