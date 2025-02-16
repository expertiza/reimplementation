require 'rails_helper'

RSpec.describe TextArea do
  let(:text_area) { TextArea.create(size: '34,1') }
  let!(:answer) { Answer.create(comments: 'test comment') }

  describe '#complete' do
    context 'when count is provided' do
      it 'generates JSON for a textarea input' do
        result = JSON.parse(text_area.complete(1))
        expect(result['action']).to eq('complete')
        expect(result['data']['count']).to eq(1)
        expect(result['data']['size']).to eq('34,1')
      end

      it 'includes any existing comments in the textarea input' do
        result = JSON.parse(text_area.complete(1, answer))
        expect(result['data']['comment']).to eq('test comment')
      end
    end

    context 'when count is not provided' do
      it 'generates JSON with default size for the textarea input' do
        text_area = TextArea.create(size: nil)
        result = JSON.parse(text_area.complete(nil))
        expect(result['data']['size']).to eq('70,1')
      end
    end
  end

  describe 'view_completed_item' do
    context 'when given a count and an answer' do
      it 'returns the formatted JSON for the completed item' do
        result = JSON.parse(text_area.view_completed_item(1, answer))
        expect(result['action']).to eq('view_completed_item')
        expect(result['data']['comment']).to eq('test comment')
      end
    end
  end
end