module ResponseHelper

  # Assigns total contribution for cake question across all reviewers to a hash map
  # Key : question_id, Value : total score for cake question
  def store_total_cake_score
    reviewee = ResponseMap.select(:reviewee_id, :type).where(id: @response.map_id.to_s).first
    @total_score = scores_per_question(reviewee.type,
                                                      @review_questions,
                                                      @participant.id,
                                                      @assignment.id,
                                                      reviewee.reviewee_id)
  end

  # Calculates the total score for each of the questions for a given participant and assignment.
  # Total scores per question, with question_id as the key and total score as the value.
  def scores_per_question(review_type, questions, participant_id, assignment_id, reviewee_id)
    questions.each_with_object({}) do |question, scores|
      next unless question.is_a?(Cake)

      score = question.running_total(review_type, question.id, participant_id, assignment_id, reviewee_id)
      scores[question.id] = score || 0
    end
  end
end
