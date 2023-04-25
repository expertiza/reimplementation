class Assignment < ApplicationRecord
  has_many :questionnaires

  def review_questionnaire_id
    Questionnaire.find_by_assignment_id id
  end

  def num_review_rounds
    2
  end

  def volume_of_review_comments(reviewer_id)
    comments, counter,
      @comments_in_round, @counter_in_round = get_all_review_comments(reviewer_id)
    num_rounds = @comments_in_round.count - 1 # ignore nil element (index 0)

    overall_avg_vol = (Lingua::EN::Readability.new(comments).num_words / (counter.zero? ? 1 : counter)).round(0)
    review_comments_volume = []
    review_comments_volume.push(overall_avg_vol)
    (1..num_rounds).each do |round|
      num = Lingua::EN::Readability.new(@comments_in_round[round]).num_words
      den = (@counter_in_round[round].zero? ? 1 : @counter_in_round[round])
      avg_vol_in_round = (num / den).round(0)
      review_comments_volume.push(avg_vol_in_round)
    end
    review_comments_volume
  end

  # Get a collection of all comments across all rounds of a review
  # as well as a count of the total number of comments. Returns the
  # above information both for totals and in a list per-round.
  def get_all_review_comments(reviewer_id)
    comments = ''
    counter = 0
    @comments_in_round = []
    @counter_in_round = []
    question_ids = Question.get_all_questions_with_comments_available(id)

    ReviewResponseMap.where(reviewed_object_id: id, reviewer_id: reviewer_id).find_each do |response_map|
      (1..num_review_rounds + 1).each do |round|
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
end
  