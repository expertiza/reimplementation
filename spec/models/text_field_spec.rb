require 'rails_helper'

RSpec.describe TextField, type: :model do
  let(:item) { TextField.create(txt: 'Sample Text Item', question_type: 'TextField', size: 'medium', break_before: true) }
  let(:answer) { Answer.new(comments: 'This is a sample answer.') }

  describe '#complete' do
    context 'when count is provided' do
      it 'returns JSON data for a paragraph with a label and input fields' do
        result = JSON.parse(item.complete(1))
        expect(result['action']).to eq('complete')
        expect(result['data']['type']).to eq('text')
        expect(result['data']['name']).to eq("response[answers][#{item.id}]")
      end
    end

    context 'when count and answer are provided' do
      it 'returns JSON data with pre-filled comment value' do
        result = JSON.parse(item.complete(1, answer))
        expect(result['data']['value']).to eq(answer.comments)
      end
    end
  end

  describe '#view_completed_item' do
    context "when the item type is 'TextField' and break_before is true" do
      it 'returns the formatted JSON for the completed item' do
        result = JSON.parse(item.view_completed_item(1, []))
        expect(result['data']['type']).to eq('text')
        expect(result['data']['break_before']).to be true
      end
    end

    context "when the item type is not 'TextField' or break_before is false" do
      let(:non_text_field_question) { TextField.create(txt: 'Non-text item', question_type: 'NotTextField', size: 'small', break_before: false) }

      it 'returns the formatted JSON for the completed item' do
        result = JSON.parse(non_text_field_question.view_completed_item(1, []))
        expect(result['data']['break_before']).to be false
      end
    end
  end
end