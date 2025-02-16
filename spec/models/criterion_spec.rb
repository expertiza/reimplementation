require 'rails_helper'

RSpec.describe Criterion, type: :model do
  let(:questionnaire) { Questionnaire.new(min_question_score: 0, max_question_score: 5) }
  let(:criterion) { Criterion.new(id: 1, question_type: 'Criterion', seq: 1.0, txt: 'test txt', weight: 1, questionnaire: questionnaire) }
  let(:answer_no_comments) { Answer.new(answer: 8) }
  let(:answer_comments) { Answer.new(answer: 3, comments: 'text comments') }

  describe '#view_item_text' do
    it 'returns the JSON' do
      json = criterion.view_item_text
      expected_json = {
        text: 'test txt',
        question_type: 'Criterion',
        weight: 1,
        score_range: '0 to 5'
      }
      expect(json).to eq(expected_json)
    end
  end

  describe '#complete' do
    it 'returns JSON without answer and no dropdown or scale specified' do
      json = criterion.complete(0, nil, 0, 5)
      expected_json = {
        label: 'test txt'
      }
      expect(json).to include(expected_json)
    end

    it 'returns JSON with a dropdown, including answer options' do
      json = criterion.complete(0, nil, 0, 5, 'dropdown')
      expected_options = (0..5).map { |score| { value: score, label: score.to_s } }
      expected_json = {
        label: 'test txt',
        response_options: {
          type: 'dropdown',
          comments: nil,
          current_answer: nil,
          options: expected_options,
        }
      }
      expect(json).to include(expected_json)
    end
  end

  describe '#dropdown_criterion_question' do
    it 'returns JSON for a dropdown without an answer selected' do
      json = criterion.dropdown_criterion_question(0, nil, 0, 5)
      expected_options = (0..5).map { |score| { value: score, label: score.to_s } }
      expected_json = {
        type: 'dropdown',
        comments: nil,
        current_answer: nil,
        options: expected_options,
      }
      expect(json).to eq(expected_json)
    end
  end

  describe '#scale_criterion_question' do
    it 'returns JSON for a scale item without an answer selected' do
      json = criterion.scale_criterion_question(0, nil, 0, 5)
      expected_json = {
        type: 'scale',
        min: 0,
        max: 5,
        comments: nil,
        current_answer: nil,
        min_label: nil,
        max_label: nil,
        size: nil,
      }
      expect(json).to eq(expected_json)
    end
  end
end