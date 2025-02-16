require 'json'

class QuizItem < Item
  has_many :quiz_question_choices, class_name: 'QuizQuestionChoice', foreign_key: 'question_id', inverse_of: false, dependent: :nullify

  def edit
  end

  def view_item_text
    choices = quiz_question_choices.map do |choice|
      {
        text: choice.txt,
        is_correct: choice.iscorrect?
      }
    end

    {
      question_text: txt,
      question_type: type,
      question_weight: weight,
      choices: choices
    }.to_json
  end

  def complete
  end

  def view_completed_item(user_answer = nil)
  end
end
