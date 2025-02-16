require 'rails_helper'

RSpec.describe TextResponse, type: :model do
  let(:text_response) { TextResponse.create(seq: '001', txt: 'Sample item content', question_type: 'TextResponse', size: 'medium', weight: 10) }

  describe '#edit' do
    let(:result) { JSON.parse(text_response.edit(1)) }

    it 'returns JSON for editing with correct action' do
      expect(result["action"]).to eq('edit')
    end

    it 'includes elements for editing item' do
      expect(result["elements"].length).to be > 0
    end
  end

  describe '#view_item_text' do
    let(:result) { JSON.parse(text_response.view_item_text) }

    it 'returns JSON for viewing item text with correct action' do
      expect(result["action"]).to eq('view_item_text')
    end

    it 'includes the item text, question_type, and weight in elements' do
      expect(result["elements"].any? { |e| e["value"] == 'Sample item content' }).to be true
      expect(result["elements"].any? { |e| e["value"] == 'TextResponse' }).to be true
      expect(result["elements"].any? { |e| e["value"].match?(/^\d+$/) }).to be true
    end
  end

end