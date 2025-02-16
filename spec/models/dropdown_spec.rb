require 'rails_helper'

RSpec.describe Dropdown, type: :model do
  describe '#edit' do
    context 'when given a count' do
      it 'returns a JSON object with the edit form for a item' do
        dropdown = Dropdown.new(txt: "Some Text", type: "dropdown", weight: 1)
        json_result = dropdown.edit(5)

        expected_result = {
          form: true,
          label: "Item 5:",
          input_type: "text",
          input_name: "item",
          input_value: "Some Text",
          min_question_score: nil,
          max_question_score: nil,
          weight: 1,
          type: 'dropdown'
        }.to_json
        expect(json_result).to eq(expected_result)
      end
    end
  end

  describe '#view_item_text' do
    let(:dropdown) { Dropdown.new }
    context 'when given valid inputs' do
      it 'returns the JSON for displaying the item text, type, weight, and score range' do
        allow(dropdown).to receive(:txt).and_return("Item 1")
        allow(dropdown).to receive(:type).and_return("Multiple Choice")
        allow(dropdown).to receive(:weight).and_return(1)
        expected_json = {
          text: "Item 1",
          type: "Multiple Choice",
          weight: 1,
          score_range: "N/A"
        }.to_json
        expect(dropdown.view_item_text).to eq(expected_json)
      end
    end
  end

  describe '#complete' do
    let(:dropdown) { Dropdown.new }
    context 'when count is provided' do
      it 'generates JSON for a select input with the given count' do
        count = 3
        expected_json = {
          dropdown_options: [
            { value: 1, selected: false },
            { value: 2, selected: false },
            { value: 3, selected: false }
          ]
        }.to_json
        expect(dropdown.complete(count)).to eq(expected_json)
      end
    end

    context 'when answer is provided' do
      it 'generates JSON with the provided answer selected' do
        count = 3
        answer = 2
        expected_json = {
          dropdown_options: [
            { value: 1, selected: false },
            { value: 2, selected: true },
            { value: 3, selected: false }
          ]
        }.to_json
        expect(dropdown.complete(count, answer)).to eq(expected_json)
      end
    end

    context 'when answer is not provided' do
      it 'generates JSON without any answer selected' do
        count = 3
        expected_json = {
          dropdown_options: [
            { value: 1, selected: false },
            { value: 2, selected: false },
            { value: 3, selected: false }
          ]
        }.to_json
        expect(dropdown.complete(count)).to eq(expected_json)
      end
    end
  end

  describe '#complete_for_alternatives' do
    let(:dropdown) { Dropdown.new }
    context 'when given an array of alternatives and an answer' do
      it 'returns JSON options with the selected alternative marked' do
        alternatives = [1, 2, 3]
        answer = 2
        expected_json = {
          dropdown_options: [
            { value: 1, selected: false },
            { value: 2, selected: true },
            { value: 3, selected: false }
          ]
        }.to_json
        expect(dropdown.complete_for_alternatives(alternatives, answer)).to eq(expected_json)
      end
    end
  end
end