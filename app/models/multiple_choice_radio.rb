require 'json'

class MultipleChoiceRadio < QuizItem
  def edit
    quiz_question_choices = QuizQuestionChoice.where(question_id: id)

    choices = quiz_question_choices.map.with_index(1) do |choice, index|
      {
        id: choice.id,
        text: choice.txt,
        is_correct: choice.iscorrect,
        position: index
      }
    end

    {
      id: id,
      question_text: txt,
      question_weight: weight,
      choices: choices
    }.to_json
  end

  def complete
    quiz_question_choices = QuizQuestionChoice.where(question_id: id)

    choices = quiz_question_choices.map.with_index(1) do |choice, index|
      {
        id: choice.id,
        text: choice.txt,
        position: index
      }
    end

    {
      question_id: id,
      question_text: txt,
      choices: choices
    }.to_json
  end

  def view_completed_item(user_answer)
    quiz_question_choices = QuizQuestionChoice.where(question_id: id)

    choices = quiz_question_choices.map do |choice|
      {
        text: choice.txt,
        is_correct: choice.iscorrect
      }
    end

    user_response = {
      answer: user_answer.first.comments,
      is_correct: user_answer.first.answer == 1
    }

    {
      question_text: txt,
      choices: choices,
      user_response: user_response
    }.to_json
  end

  def isvalid(choice_info)
    valid = true
    error_message = nil

    if txt.blank?
      valid = false
      error_message = 'Please make sure all questions have text'
    elsif choice_info.values.any? { |choice| choice[:txt].blank? }
      valid = false
      error_message = 'Please make sure every item has text for all options'
    end

    correct_count = choice_info.count { |_idx, choice| choice[:iscorrect] == '1' }

    if correct_count != 1
      valid = false
      error_message = 'Please select exactly one correct answer for the item'
    end

    {
      valid: valid,
      error: error_message
    }.to_json
  end
end