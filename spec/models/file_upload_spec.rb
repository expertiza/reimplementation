require 'rails_helper'




RSpec.describe FileUpload do

  # Adjust the let statement to not include 'type' and 'weight' if they are not recognized attributes.

  let(:upload_file) { FileUpload.new(id: 1, seq: '1', txt: 'Sample item content', question_type: 'FileUpload') }




  describe '#edit' do

    context 'when given a count' do

      let(:json_response) { JSON.parse(upload_file.edit(1)) }




      it 'returns JSON with a correct structure for editing' do

        expect(json_response["action"]).to eq('edit')

        expect(json_response["elements"]).to be_an(Array)

      end




      it 'includes a "Remove" link in the elements' do

        link_element = json_response["elements"].find { |el| el["text"] == "Remove" }

        expect(link_element).not_to be_nil

        expect(link_element["href"]).to include("/questions/1")

      end




      it 'includes an input field for the sequence' do

        seq_element = json_response["elements"].find { |el| el["name"]&.include?("seq") }

        expect(seq_element).not_to be_nil

        expect(seq_element["value"]).to eq('1')

      end




      it 'includes an input field for the id' do

        id_element = json_response["elements"].find { |el| el["name"]&.include?("id") }

        expect(id_element).not_to be_nil

        expect(id_element["value"]).to eq('1')

      end




      it 'includes a textarea for editing the item content' do

        textarea_element = json_response["elements"].find { |el| el["name"]&.include?("txt") }

        expect(textarea_element).not_to be_nil

        expect(textarea_element["value"]).to eq('Sample item content')

      end




      it 'includes an input field for the item type, disabled' do

        type_element = json_response["elements"].find { |el| el["name"]&.include?("question_type") }

        expect(type_element).not_to be_nil

        expect(type_element["disabled"]).to be true

      end




      it 'does not include an explicit cell for weight, as it is not applicable' do

        weight_element = json_response["elements"].none? { |el| el.has_key?("weight") }

        expect(weight_element).to be true

      end

    end

  end




  describe '#view_item_text' do

    context 'when given valid input' do

      let(:json_response) { JSON.parse(upload_file.view_item_text) }




      it 'returns JSON for displaying a item' do

        expect(json_response["action"]).to eq('view_item_text')

        expect(json_response["elements"].map { |el| el["value"] }).to include('Sample item content', 'FileUpload', "", '1','—')

      end

    end

  end




  describe '#complete' do

    it 'implements the logic for completing a item' do

      # Write your test for the complete method logic here.

    end

  end




  describe '#view_completed_item' do

    it 'implements the logic for viewing a completed item by a student' do

      # Write your test for the view_completed_item method logic here.

    end

  end

end