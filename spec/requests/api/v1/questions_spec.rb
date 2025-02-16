require 'swagger_helper'
require 'json_web_token'
# Rspec tests for questions controller
RSpec.describe 'api/v1/questions', type: :request do
  before(:all) do
    @roles = create_roles_hierarchy
  end

  let(:instructor) { User.create(
    name: "profa",
    password_digest: "password",
    role_id: @roles[:instructor].id,
    full_name: "Prof A",
    email: "testuser@example.com",
    mru_directory_path: "/home/testuser",
    ) }

  let(:token) { JsonWebToken.encode({id: instructor.id}) }
  let(:Authorization) { "Bearer #{token}" }
  path '/api/v1/questions' do
    let(:questionnaire) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 1',
        questionnaire_type: 'AuthorFeedbackReview',
        private: true,
        min_question_score: 0,
        max_question_score: 10,
        instructor_id: instructor.id
      )
    end

    let(:question1) do
      questionnaire
      Item.create(
        seq: 1, 
        txt: "test item 1",
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire
      )
    end

    let(:question2) do
      questionnaire
      Item.create(
        seq: 2, 
        txt: "test item 2",
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
        questionnaire: questionnaire
      )
    end

    # get request on /api/v1/questions returns 200 successful response when it returns list of questions present in the database
    get('list questions') do
      tags 'Questions'
      produces 'application/json'
      response(200, 'successful') do
        run_test! do
          expect(response.body.size).to eq(2)
        end
      end
    end

    post('create item') do
      tags 'Questions'
      consumes 'application/json'
      produces 'application/json'
      
      let(:valid_question_params) do
        {
          questionnaire_id: questionnaire.id,
          txt: "test item",
          question_type: "multiple_choice", 
          break_before: false,
          weight: 10
        }
      end
      # Creation of dummy objects for the test with the help of let statements
      let(:invalid_question_params1) do
        {
          questionnaire_id: nil ,
          txt: "test item",
          question_type: "multiple_choice", 
          break_before: false,
          weight: 10
        }
      end

      let(:invalid_question_params2) do
        {
          questionnaire_id: questionnaire.id ,
          txt: "test item",
          question_type: nil, 
          break_before: false,
          weight: 10
        }
      end

      parameter name: :item, in: :body, schema: {
        type: :object,
        properties: {
          weight: { type: :integer },
          questionnaire_id: { type: :integer },
          break_before: { type: :boolean },
          txt: { type: :string },
          question_type: { type: :string },
        },
        required: %w[weight questionnaire_id break_before txt question_type]      
      }

      # post request on /api/v1/questions returns 201 created response and creates a item with given valid parameters
      response(201, 'created') do
        let(:item) do
          questionnaire
          Item.create(valid_question_params)
        end
        run_test! do
          expect(response.body).to include('"seq":1')
        end
      end

      # post request on /api/v1/questions returns 404 not found when questionnaire id for the given item is not present in the database
      response(404, 'questionnaire id not found') do
        let(:item) do
          instructor
          Item.create(invalid_question_params1)
        end
        run_test!
      end

      # post request on /api/v1/questions returns 422 unprocessable entity when incorrect parameters are passed to create a item
      response(422, 'unprocessable entity') do
        let(:item) do
          instructor
          Item.create(invalid_question_params2)
        end
        run_test!
      end

    end

  end

  path '/api/v1/questions/{id}' do

    parameter name: 'id', in: :path, type: :integer

    let(:questionnaire) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 1',
        questionnaire_type: 'AuthorFeedbackReview',
        private: true,
        min_question_score: 0,
        max_question_score: 10,
        instructor_id: instructor.id
      )
    end

    let(:question1) do
      questionnaire
      Item.create(
        seq: 1, 
        txt: "test item 1",
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire
      )
    end

    let(:question2) do
      questionnaire
      Item.create(
        seq: 2, 
        txt: "test item 2",
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
        questionnaire: questionnaire
      )
    end

    
    let(:id) do
      questionnaire
      question1
      question1.id 
    end



    get('show item') do
      tags 'Questions'
      produces 'application/json'

      # get request on /api/v1/questions/{id} returns 200 successful response and returns item with given item id
      response(200, 'successful') do
        run_test! do
          expect(response.body).to include('"txt":"test item 1"')
        end
      end

      # get request on /api/v1/questions/{id} returns 404 not found response when item id is not present in the database
      response(404, 'not_found') do
        let(:id) { 'invalid' }
          run_test! do
            expect(response.body).to include("Couldn't find Item")
          end
      end
    end

    put('update item') do
      tags 'Questions'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          break_before: { type: :boolean },
          seq: { type: :integer }
        }
      }
      
      # put request on /api/v1/questions/{id} returns 200 successful response and updates parameters of item with given item id
      response(200, 'successful') do
        let(:body_params) do
          {
            break_before: true
          }
        end
        run_test! do
          expect(response.body).to include('"break_before":true')
        end
      end

      # put request on /api/v1/questions/{id} returns 404 not found response when item with given id is not present in the database
      response(404, 'not found') do
        let(:id) { 0 }
        let(:body_params) do
          {
            break_before: true
          }
        end
        run_test! do
          expect(response.body).to include("Not Found")
        end
      end

      # put request on /api/v1/questions/{id} returns 422 unprocessable entity when incorrect parameters are passed for item with given item id
      response(422, 'unprocessable entity') do
        let(:body_params) do
          {
            seq: "Dfsd"
          }
        end
        schema type: :object
        run_test! do
          expect(response.body).to_not include('"seq":"Dfsd"')
        end
      end  


    end

    patch('update item') do
      tags 'Questions'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          break_before: { type: :boolean },
          seq: { type: :integer }
        }
      }
      
      # patch request on /api/v1/questions/{id} returns 200 successful response and updates parameters of item with given item id
      response(200, 'successful') do
        let(:body_params) do
          {
            break_before: true
          }
        end
        run_test! do
          expect(response.body).to include('"break_before":true')
        end
      end

      # patch request on /api/v1/questions/{id} returns 404 not found response when item with given id is not present in the database
      response(404, 'not found') do
        let(:id) { 0 }
        let(:body_params) do
          {
            break_before: true
          }
        end
        run_test! do
          expect(response.body).to include("Couldn't find Item")
        end
      end

      # patch request on /api/v1/questions/{id} returns 422 unprocessable entity when incorrect parameters are passed for item with given item id
      response(422, 'unprocessable entity') do
        let(:body_params) do
          {
            seq: "Dfsd"
          }
        end
        schema type: :object
        run_test! do
          expect(response.body).to_not include('"seq":"Dfsd"')
        end
      end
    end


    delete('delete item') do

      tags 'Questions'
      produces 'application/json'

      # delete request on /api/v1/questions/{id} returns 204 successful response when it deletes item with given item id present in the database
      response(204, 'successful') do
        run_test! do
          expect(Item.exists?(id)).to eq(false)
        end
      end

      # delete request on /api/v1/questions/{id} returns 404 not found response when item with given item id is not present in the database
      response(404, 'not found') do
        let(:id) { 0 }
        run_test! do
          expect(response.body).to include("Couldn't find Item")
        end
      end
    end

  end

  path '/api/v1/questions/delete_all/questionnaire/{id}' do
    parameter name: 'id', in: :path, type: :integer

    # Creation of dummy objects for the test with the help of let statements
    let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
    
    let(:instructor) do 
      role
      Instructor.create(name: 'testinstructor', email: 'test@test.com', full_name: 'Test Instructor', password: '123456', role: role)
    end

    let(:questionnaire) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 1',
        questionnaire_type: 'AuthorFeedbackReview',
        private: true,
        min_question_score: 0,
        max_question_score: 10,
        instructor_id: instructor.id
      )
    end

    let(:question1) do
      questionnaire
      Item.create(
        seq: 1, 
        txt: "test item 1",
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire
      )
    end

    let(:question2) do
      questionnaire
      Item.create(
        seq: 2, 
        txt: "test item 2",
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
        questionnaire: questionnaire
      )
    end

    
    let(:id) do
      questionnaire
      question1
      question2
      questionnaire.id 
    end

    delete('delete all questions') do
      tags 'Questions'
      produces 'application/json'

      # delete method on /api/v1/questions/delete_all/questionnaire/{id} returns 200 successful response when all questions with given questionnaire id are deleted
      response(200, 'successful') do
        run_test! do
          expect(Item.where(questionnaire_id: id).count).to eq(0)
        end
      end

      # delete request on /api/v1/questions/delete_all/questionnaire/{id} returns 404 not found response when questionnaire id is not found in the database
      response(404, 'not found') do
        let(:id) { 0 }
        run_test! do
          expect(response.body).to include("Couldn't find Questionnaire")
        end
      end
    end
  end

  path '/api/v1/questions/show_all/questionnaire/{id}' do
    parameter name: 'id', in: :path, type: :integer

    # Creation of dummy objects for the test with the help of let statements
    let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
    
    let(:instructor) do 
      role
      Instructor.create(name: 'testinstructor', email: 'test@test.com', full_name: 'Test Instructor', password: '123456', role: role)
    end

    let(:questionnaire) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 1',
        questionnaire_type: 'AuthorFeedbackReview',
        private: true,
        min_question_score: 0,
        max_question_score: 10,
        instructor_id: instructor.id
      )
    end

    let(:question1) do
      questionnaire
      Item.create(
        seq: 1, 
        txt: "test item 1",
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire
      )
    end

    let(:questionnaire2) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 2',
        questionnaire_type: 'AuthorFeedbackReview',
        private: true,
        min_question_score: 0,
        max_question_score: 10,
        instructor_id: instructor.id
      )
    end

    let(:question2) do
      questionnaire2
      Item.create(
        seq: 2, 
        txt: "test item 2",
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire2
      )
    end

    let(:question3) do
      questionnaire2
      Item.create(
        seq: 3, 
        txt: "test item 3",
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
        questionnaire: questionnaire2
      )
    end

    
    let(:id) do
      questionnaire
      questionnaire2
      question1
      question2
      question3
      questionnaire.id 
    end

    get('show all questions') do
      tags 'Questions'
      produces 'application/json'

      # get method on /api/v1/questions/show_all/questionnaire/{id} returns 200 successful response when all questions with given questionnaire id are shown
      response(200, 'successful') do
        run_test! do
          expect(Item.where(questionnaire_id: id).count).to eq(1)
          expect(response.body).to_not include('"questionnaire_id: "' + questionnaire2.id.to_s)
        end
      end

      # get request on /api/v1/questions/delete_all/questionnaire/{id} returns 404 not found response when questionnaire id is not found in the database
      response(404, 'not found') do
        let(:id) { 0 }
        run_test! do
          expect(response.body).to include("Couldn't find Questionnaire")
        end
      end
    end
  end

  path '/api/v1/questions/types' do

    # Creation of dummy objects for the test with the help of let statements
    let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
    
    let(:instructor) do 
      role
      Instructor.create(name: 'testinstructor', email: 'test@test.com', full_name: 'Test Instructor', password: '123456', role: role)
    end

    let(:questionnaire) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 1',
        questionnaire_type: 'AuthorFeedbackReview',
        private: true,
        min_question_score: 0,
        max_question_score: 10,
        instructor_id: instructor.id
      )
    end

    let(:question1) do
      questionnaire
      Item.create(
        seq: 1, 
        txt: "test item 1",
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire
      )
    end

    let(:question2) do
      questionnaire
      Item.create(
        seq: 2, 
        txt: "test item 2",
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
        questionnaire: questionnaire
      )
    end

    get('item types') do
      tags 'Questions'
      produces 'application/json'
      # get request on /api/v1/questions/types returns types of questions present in the database
      response(200, 'successful') do
        run_test! do
          expect(response.body.size).to eq(2)
        end
      end
    end
  
  end
end