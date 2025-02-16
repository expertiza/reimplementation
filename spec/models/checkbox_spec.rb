require 'rails_helper'

RSpec.describe Checkbox do
  let!(:checkbox) { Checkbox.new(id: 10, question_type: 'Checkbox', seq: 1.0, txt: 'test txt', weight: 11) }
  let!(:answer) { Answer.new(answer: 1) }

  describe '#edit' do
    it 'returns the JSON' do
      json = checkbox.edit(0)
      expected_json = {
        remove_button: { type: 'remove_button', action: 'delete', href: "/questions/10", text: 'Remove' },
        seq: { type: 'seq', input_size: 6, value: 1.0, name: "item[10][seq]", id: "question_10_seq" },
        item: { type: 'textarea', cols: 50, rows: 1, name: "item[10][txt]", id: "question_10_txt", placeholder: 'Edit item content here', content: 'test txt' },
        type: { type: 'text', input_size: 10, disabled: true, value: 'Checkbox', name: "item[10][type]", id: "question_10_type" },
        weight: { type: 'weight', placeholder: 'UnscoredItem does not need weight' }
      }
      expect(json).to eq(expected_json)
    end
  end

  describe '#complete' do
    let(:checkbox) { Checkbox.new(id: 10, question_type: 'Checkbox', seq: 1.0, txt: 'test txt', weight: 11) }
    let(:count) { 1 }
    let(:answer) { OpenStruct.new(answer: 1) } # Mocking Answer object

    context 'when an answer is provided' do
      it 'returns the expected completion structure' do
        result = checkbox.complete(count, answer)

        expect(result[:previous_question]).to be_present
        expect(result[:inputs]).to be_an(Array)
        expect(result[:label]).to include(text: checkbox.txt)
        expect(result[:script]).to include("checkbox#{count}Changed()")
        expect(result[:inputs].last[:checked]).to be true
      end
    end

    context 'when no answer is provided' do
      let(:answer) { OpenStruct.new(answer: nil) }

      it 'returns a structure with the checkbox not checked' do
        result = checkbox.complete(count, answer)
        expect(result[:inputs].last[:checked]).to be false
      end
    end
  end

  describe '#view_item_text' do
    it 'returns the JSON' do
      json = checkbox.view_item_text
      expected_json = {
        content: 'test txt',
        type: 'Checkbox',
        weight: '11',
        checked_state: 'Checked/Unchecked'
      }
      expect(json).to eq(expected_json)
    end
  end

  describe '#view_completed_item' do
    it 'returns the JSON' do
      json = checkbox.view_completed_item(0, answer)
      expected_json = {
        previous_question: { type: 'other' },
        answer: {
          number: 0,
          image: 'Check-icon.png',
          content: 'test txt',
          bold: true
        },
        if_column_header: 'end'
      }
      expect(json).to eq(expected_json)
    end
  end
end