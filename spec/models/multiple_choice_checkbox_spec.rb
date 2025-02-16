require 'rails_helper'

RSpec.describe MultipleChoiceCheckbox, type: :model do
  let(:multiple_choice_checkbox) { MultipleChoiceCheckbox.new(id: 1, txt: 'Test item:', weight: 1) } # Adjust as needed

  describe '#edit' do
    it 'returns the JSON structure for editing' do
      qc = instance_double('QuizQuestionChoice', iscorrect: true, txt: 'item text', id: 1)
      allow(QuizQuestionChoice).to receive(:where).with(question_id: 1).and_return([qc, qc, qc, qc])

      expected_structure = {
        "id" => 1,
        "question_text" => "Test item:",
        "weight" => 1,
        "choices" => [
          {"id" => 1, "text" => "item text", "is_correct" => true, "position" => 1},
          {"id" => 1, "text" => "item text", "is_correct" => true, "position" => 2},
          {"id" => 1, "text" => "item text", "is_correct" => true, "position" => 3},
          {"id" => 1, "text" => "item text", "is_correct" => true, "position" => 4}
        ]
      }.to_json

      expect(multiple_choice_checkbox.edit).to eq(expected_structure)
    end
  end

  describe '#isvalid' do
    context 'when the item itself does not have txt' do
      it 'returns a JSON with error message' do
        allow(multiple_choice_checkbox).to receive_messages(txt: '', id: 1)
        questions = { '1' => { txt: 'item text', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '1' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expected_response = { valid: false, error: 'Please make sure all questions have text' }.to_json
        expect(multiple_choice_checkbox.isvalid(questions)).to eq(expected_response)
      end
    end

    context 'when a choice does not have txt' do
      it 'returns a JSON with error message' do
        questions = { '1' => { txt: '', iscorrect: '1' }, '2' => { txt: '', iscorrect: '1' }, '3' => { txt: '', iscorrect: '0' }, '4' => { txt: '', iscorrect: '0' } }
        expected_response = { valid: true, error: nil }.to_json
        expect(multiple_choice_checkbox.isvalid(questions)).to eq(expected_response)
      end
    end

    context 'when no choices are correct' do
      it 'returns a JSON with error message' do
        questions = { '1' => { txt: 'item text', iscorrect: '0' }, '2' => { txt: 'item text', iscorrect: '0' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expected_response = { valid: false, error: 'Please select a correct answer for all questions' }.to_json
        expect(multiple_choice_checkbox.isvalid(questions)).to eq(expected_response)
      end
    end

    context 'when only one choice is correct' do
      it 'returns a JSON with error message' do
        questions = { '1' => { txt: 'item text', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '0' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expected_response = { valid: false, error: 'A multiple-choice checkbox item should have more than one correct answer.' }.to_json
        expect(multiple_choice_checkbox.isvalid(questions)).to eq(expected_response)
      end
    end

    context 'when 2 choices are correct' do
      it 'returns valid status' do
        questions = { '1' => { txt: 'item text', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '1' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expected_response = { valid: true, error: nil}.to_json
        expect(multiple_choice_checkbox.isvalid(questions)).to eq(expected_response)
      end
    end
  end
end