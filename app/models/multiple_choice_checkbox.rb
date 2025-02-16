require 'json'

class MultipleChoiceCheckbox < QuizItem
  def edit
    quiz_question_choices = QuizQuestionChoice.where(question_id: id)

    data = {
      id: id,
      question_text: txt,
      weight: weight,
      choices: quiz_question_choices.each_with_index.map do |choice, index|
        {
          id: choice.id,
          text: choice.txt,
          is_correct: choice.iscorrect,
          position: index + 1
        }
      end
    }

    data.to_json
  end

  def complete
    quiz_question_choices = QuizQuestionChoice.where(question_id: id)

    data = {
      id: id,
      question_text: txt,
      choices: quiz_question_choices.map do |choice|
        { text: choice.txt }
      end
    }

    data.to_json
  end

  def view_completed_item(user_answer)
    quiz_question_choices = QuizQuestionChoice.where(question_id: id)

    data = {
      question_choices: quiz_question_choices.map do |choice|
        {
          text: choice.txt,
          is_correct: choice.iscorrect
        }
      end,
      user_answers: user_answer.map do |answer|
        {
          is_correct: answer.answer == 1,
          comments: answer.comments
        }
      end
    }

    data.to_json
  end

  def isvalid(choice_info)
    error_message = nil
    error_message = 'Please make sure all questions have text' if txt.blank?

    correct_count = choice_info.count { |_idx, value| value[:iscorrect] == '1' }

    if correct_count.zero?
      error_message = 'Please select a correct answer for all questions'
    elsif correct_count == 1
      error_message = 'A multiple-choice checkbox item should have more than one correct answer.'
    end

    { valid: error_message.nil?, error: error_message }.to_json
  end
end