require 'swagger_helper'

RSpec.describe 'SignUpSheetController API', type: :request do

  path '/api/v1/sign_up_sheet' do

    get('check if sheet can be access via index') do
      tags 'SignUpSheet'
      produces 'application/json'

      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/sign_up_sheet/load_all_selected_topics' do
    get('list the topics') do
      tags 'SignUpSheet'
      produces 'application/json'
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/sign_up_sheet/delete_all_selected_topics' do
    post('test for all selected topics') do
      tags 'SignUpSheet'
      produces 'application/json'
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/sign_up_sheet/delete_all_topics_for_assignment' do
    post('test to delete topics') do
      tags 'SignUpSheet'
      produces 'application/json'
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

end
