# frozen_string_literal: true

module ScorableHelper

  # Computes the total points awarded for all scores on the instance
  def calculate_total_score
    # Only count the scorable questions, only when the answer is not nil (we accept nil as
    # answer for scorable questions, and they will not be counted towards the total score)

    sum = 0
    question_ids = scores.map(&:question_id)

    # We use find with order here to ensure that the list of questions we get is in the same order as that of question_ids
    questions = Item.find_with_order(question_ids)

    scores.each_with_index do |score, idx|
      item = questions[idx]
      sum += score.answer * questions[idx].weight if !score.answer.nil? && item.scorable?
    end

    sum
  end

  # Returns the average score across all of the instances scores as an integer (0-100)
  def average_score
    if maximum_score.zero?
      0
    else
      ((calculate_total_score.to_f / maximum_score.to_f) * 100).round
    end
  end

  # Returns the maximum possible total score for all scores on the instance
  def maximum_score
    # Only count the scorable questions, only when the answer is not nil (we accept nil as
    # answer for scorable questions, and they will not be counted towards the total score)
    total_weight = 0
    question_ids = scores.map(&:question_id)

    # We use find with order here to ensure that the list of questions we get is in the same order as that of question_ids
    questions = Item.find_with_order(question_ids)

    scores.each_with_index do |score, idx|
      total_weight += questions[idx].weight unless score.answer.nil? || !questions[idx].scorable?
    end

    questionnaire = if scores.empty?
                      questionnaire_by_answer(nil)
                    else
                      questionnaire_by_answer(scores.first)
                    end
    total_weight * questionnaire.max_question_score
  end

  def questionnaire_by_answer(answer)
    if answer.nil?
      # Answers can be nil in cases such as "Upload File" being the only item.
      map = ResponseMap.find(map_id)
      # E-1973 either get the assignment from the participant or the map itself
      assignment = map.response_assignment
      questionnaire = Questionnaire.find(assignment.review_questionnaire_id)
    else
      questionnaire = Item.find(answer.question_id).questionnaire
    end
    questionnaire
  end
end
