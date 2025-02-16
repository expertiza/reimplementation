require 'rails_helper'

RSpec.describe MultipleChoiceRadio, type: :model do
  let(:multiple_choice_radio) { MultipleChoiceRadio.new(id: 1, txt: 'Test item', weight: 1) }
  let(:quiz_question_choices) do
    [
      instance_double('QuizQuestionChoice', id: 1, txt: 'Choice 1', iscorrect: true),
      instance_double('QuizQuestionChoice', id: 2, txt: 'Choice 2', iscorrect: false)
    ]
  end

  before do
    allow(QuizQuestionChoice).to receive(:where).with(question_id: 1).and_return(quiz_question_choices)
  end

  describe '#edit' do
    context 'when editing a quiz item' do
      it 'returns JSON for the item edit form' do
        expected_json = {
          id: 1,
          question_text: 'Test item',
          question_weight: 1,
          choices: [
            {id: 1, text: 'Choice 1', is_correct: true, position: 1},
            {id: 2, text: 'Choice 2', is_correct: false, position: 2}
          ]
        }.to_json

        expect(multiple_choice_radio.edit).to eq(expected_json)
      end
    end
  end

  describe '#complete' do
    context 'when given a valid item id' do
      it 'returns JSON for a quiz item with choices' do
        expected_json = {
          question_id: 1,
          question_text: 'Test item',
          choices: [
            {id: 1, text: 'Choice 1', position: 1},
            {id: 2, text: 'Choice 2', position: 2}
          ]
        }.to_json

        expect(multiple_choice_radio.complete).to eq(expected_json)
      end
    end
  end

  describe "#view_completed_item" do
    let(:user_answer) { [instance_double('UserAnswer', answer: 1, comments: 'Choice 1')] }

    context "when user answer is correct" do
      it "includes correctness in the response" do
        expected_json = {
          question_text: 'Test item',
          choices: [
            {text: 'Choice 1', is_correct: true},
            {text: 'Choice 2', is_correct: false}
          ],
          user_response: {answer: 'Choice 1', is_correct: true}
        }.to_json

        expect(multiple_choice_radio.view_completed_item(user_answer)).to eq(expected_json)
      end
    end
  end

  describe '#isvalid' do
    context 'when choice_info is valid' do
      it 'returns valid status' do
        choice_info = {
          '0' => { txt: 'Choice 1', iscorrect: '0' },
          '1' => { txt: 'Choice 2', iscorrect: '1' }
        }
        expected_response = { valid: true, error: nil }.to_json

        expect(multiple_choice_radio.isvalid(choice_info)).to eq(expected_response)
      end
    end

    context 'when choice_info has empty text for an option' do
      it 'returns an error message' do
        choice_info = {'0' => {txt: '', iscorrect: '1'}, '1' => {txt: 'Choice 2', iscorrect: '0'}}
        expected_response = {valid: false, error: 'Please make sure every item has text for all options'}.to_json

        expect(multiple_choice_radio.isvalid(choice_info)).to eq(expected_response)
      end
    end
  end
end