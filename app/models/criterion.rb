class Criterion < ScoredItem
    validates :size, presence: true
  
    def edit
      {
        remove_link: "/questions/#{id}",
        sequence_input: seq.to_s,
        question_text: txt,
        question_type: question_type,
        weight: weight.to_s,
        size: size.to_s,
        max_label: max_label,
        min_label: min_label
      }
    end
  
    def view_item_text
      question_data = {
        text: txt,
        question_type: question_type,
        weight: weight,
        score_range: "#{questionnaire.min_question_score} to #{questionnaire.max_question_score}"
      }
  
      question_data[:score_range] = "(#{min_label}) " + question_data[:score_range] + " (#{max_label})" if max_label && min_label
      question_data
    end
  
    def complete(count,answer = nil, questionnaire_min, questionnaire_max, dropdown_or_scale)
      question_advices = QuestionAdvice.to_json_by_question_id(id)
      advice_total_length = question_advices.sum { |advice| advice.advice.length unless advice.advice.blank? }
  
      response_options = if dropdown_or_scale == 'dropdown'
                           dropdown_criterion_question(count, answer, questionnaire_min, questionnaire_max)
                         elsif dropdown_or_scale == 'scale'
                           scale_criterion_question(count, answer, questionnaire_min, questionnaire_max)
                         end
  
      advice_section = question_advices.empty? || advice_total_length.zero? ? nil : advices_criterion_question(count, question_advices)
  
      {
        label: txt,
        advice: advice_section,
        response_options: response_options
      }.compact # Use .compact to remove nil values
    end
  
    # Assuming now these methods should be public based on the test cases
    def dropdown_criterion_question(count,answer, questionnaire_min, questionnaire_max)
      options = (questionnaire_min..questionnaire_max).map do |score|
        option = { value: score, label: score.to_s }
        option[:selected] = 'selected' if answer && score == answer.answer
        option
      end
      { type: 'dropdown', options: options, current_answer: answer.try(:answer), comments: answer.try(:comments) }
    end
  
    def scale_criterion_question(count,answer, questionnaire_min, questionnaire_max)
      {
        type: 'scale',
        min: questionnaire_min,
        max: questionnaire_max,
        current_answer: answer.try(:answer),
        comments: answer.try(:comments),
        min_label: min_label,
        max_label: max_label,
        size: size
      }
    end
  
    private
  
    def advices_criterion_question(question_advices)
      question_advices.map do |advice|
        {
          score: advice.score,
          advice: advice.advice
        }
      end
    end
  end