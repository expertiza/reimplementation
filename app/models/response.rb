class Response < ApplicationRecord
  include ScorableMixin
  include MailMixin
  include ReviewCommentMixin

  belongs_to :response_map, class_name: 'ResponseMap', foreign_key: 'map_id', inverse_of: false
  has_many :scores, class_name: 'Answer', foreign_key: 'response_id', dependent: :destroy, inverse_of: false

  # Get a collection of all comments across all rounds of a review
  # as well as a count of the total number of comments. Returns the
  # above information both for totals and in a list per-round.
  def self.get_all_review_comments(assignment_id, reviewer_id)
    comments = ''
    counter = 0
    @comments_in_round = []
    @counter_in_round = []
    assignment = Assignment.find(assignment_id)
    question_ids = Question.get_all_questions_with_comments_available(assignment_id)

    # Since reviews can have multiple rounds we need to iterate over all of them
    # to build our response.
    ReviewResponseMap.where(reviewed_object_id: assignment_id, reviewer_id: reviewer_id).find_each do |response_map|
      (1..assignment.num_review_rounds + 1).each do |round|
        @comments_in_round[round] = ''
        @counter_in_round[round] = 0
        last_response_in_current_round = response_map.response.select { |r| r.round == round }.last
        next if last_response_in_current_round.nil?

        last_response_in_current_round.scores.each do |answer|
          comments += answer.comments if question_ids.include? answer.question_id
          @comments_in_round[round] += (answer.comments ||= '')
        end
        additional_comment = last_response_in_current_round.additional_comment
        comments += additional_comment
        counter += 1
        @comments_in_round[round] += additional_comment
        @counter_in_round[round] += 1
      end
    end
    [comments, counter, @comments_in_round, @counter_in_round]
  end

  # Gets the number of previous reviews
  def self.prev_reviews_count(existing_responses, current_response)
    count = 0
    existing_responses.each do |existing_response|
      unless existing_response.id == current_response.id # the current_response is also in existing_responses array
        count += 1
      end
    end
    count
  end

  # Gets the average score of all previous reviews
  def self.prev_reviews_avg_scores(existing_responses, current_response)
    scores_assigned = []
    existing_responses.each do |existing_response|
      unless existing_response.id == current_response.id # the current_response is also in existing_responses array
        scores_assigned << existing_response.aggregate_questionnaire_score.to_f / existing_response.maximum_score
      end
    end
    scores_assigned.sum / scores_assigned.size.to_f
  end

  # Computes the total score awarded for a review
  def aggregate_questionnaire_score
    # only count the scorable questions, only when the answer is not nil
    # we accept nil as answer for scorable questions, and they will not be counted towards the total score
    sum = 0
    scores.each do |s|
      question = Question.find(s.question_id)
      # For quiz responses, the weights will be 1 or 0, depending on if correct
      sum += s.answer * question.weight unless s.answer.nil? || !question.is_a?(ScoredQuestion)
    end
    sum
  end

  # Gets the latest response made by a reviewer for a reviewee
  def self.get_latest_response(assignment, reviewer, reviewee)
    map_id = ResponseMap.find_by(assignment: assignment, reviewer: reviewer, reviewee: reviewee)
    Response.where(map_id: map_id).last
  end

  # Gets all of the responses made by a reviewer for a reviewee
  def self.get_all_responses(assignment, reviewer, reviewee)
    map_id = ResponseMap.find_by(assignment: assignment, reviewer: reviewer, reviewee: reviewee)
    Response.where(map_id: map_id).all
  end
end
