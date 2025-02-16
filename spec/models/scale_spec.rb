require 'rails_helper'

RSpec.describe Scale, type: :model do

  subject { Scale.new }

  before do
    subject.txt = "Rate your experience"
    subject.type = "Scale"
    subject.weight = 1
    subject.min_label = "Poor"
    subject.max_label = "Excellent"
    subject.min_question_score = 1
    subject.max_question_score = 5
    subject.answer = 3
  end

  describe "#edit" do

    it 'returns a JSON object with item text, type, weight, and score range' do
      scale = Scale.new(txt: 'Scale Item', type: 'scale', weight: 2, min_question_score: 0, max_question_score: 10)

      json_result = scale.edit

      expected_result = {
        form: true,
        label: "Item:",
        input_type: "text",
        input_name: "item",
        input_value: "Scale Item",
        min_question_score: 0,
        max_question_score: 10,
        weight: 2,
        type: 'scale'
      }.to_json
      expect(json_result).to eq(expected_result)
    end
  end

  describe "#view_item_text" do
    it "returns JSON containing the item text" do
      expected_json = {
        text: "Rate your experience",
        type: "Scale",
        weight: 1,
        score_range: "1..5"
      }.to_json
      expect(subject.view_item_text).to eq(expected_json)
    end
  end

  describe "#complete" do
    it "returns JSON with scale options" do
      expected_json = { scale_options: [
        { value: 1, selected: false },
        { value: 2, selected: false },
        { value: 3, selected: true },
        { value: 4, selected: false },
        { value: 5, selected: false }
      ] }.to_json
      expect(subject.complete).to eq(expected_json)
    end
  end

  describe "#view_completed_item" do
    context "when the item has been answered" do
      it "returns JSON with the count, answer, and questionnaire_max" do
        options = { count: 10, answer: 3, questionnaire_max: 50 }
        expected_json = options.to_json
        expect(subject.view_completed_item(options)).to eq(expected_json)
      end
    end

    context "when the item has not been answered" do
      it "returns a message indicating the item was not answered" do
        expected_json = { message: "Item not answered." }.to_json
        expect(subject.view_completed_item).to eq(expected_json)
      end
    end
  end
end