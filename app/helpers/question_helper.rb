module QuestionHelper
    def edit_common(label = nil,min_question_score = nil, max_question_score = nil, txt ,weight, type)
      {
        form: true,
        label: label,
        input_type: 'text',
        input_name: 'item',
        input_value: txt,
        min_question_score: min_question_score,
        max_question_score: max_question_score,
        weight: weight,
        type: type
      }
    end
  
    def view_item_text_common(text, type, weight, score_range)
      { text: text, type: type, weight: weight, score_range: score_range }
    end
  end