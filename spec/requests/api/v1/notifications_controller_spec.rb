require 'swagger_helper'

RSpec.describe 'Notifications API', type: :request do
  let(:user) { create(:user, name: 'test_user') }
  let(:course) { create(:course, name: 'Ruby 101', instructor_id: user.id, institution_id: 1) }
  let(:notification) { create(:notification, course: course, user: user, subject: 'Test Notification') }

  path '/api/v1/notifications' do
    get('list notifications') do
      tags 'Notifications'
      produces 'application/json'

      response(200, 'Success') do
        let!(:notifications) { create_list(:notification, 5, user: user, course: course) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test! do |response|
          expect(JSON.parse(response.body).size).to eq(5)
        end
      end
    end

    post('create notification') do
      tags 'Notifications'
      consumes 'application/json'
      parameter name: :notification, in: :body, schema: {
        type: :object,
        properties: {
          subject: { type: :string },
          description: { type: :string },
          expiration_date: { type: :string, format: :date },
          active_flag: { type: :boolean },
          course_id: { type: :integer }
        },
        required: %w[subject course_id]
      }

      response(201, 'Created') do
        let(:notification) { { subject: 'New Notification', description: 'Details', expiration_date: Date.today + 7, course_id: course.id } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(422, 'Unprocessable Entity') do
        let(:notification) { { description: 'Details', expiration_date: Date.today + 7, course_id: course.id } }

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

  path '/api/v1/notifications/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the notification'

    get('show notification') do
      tags 'Notifications'
      response(200, 'Success') do
        let(:id) { notification.id }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }

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

    patch('update notification') do
      tags 'Notifications'
      consumes 'application/json'
      parameter name: :notification, in: :body, schema: {
        type: :object,
        properties: {
          subject: { type: :string },
          description: { type: :string },
          expiration_date: { type: :string, format: :date },
          active_flag: { type: :boolean }
        }
      }

      response(200, 'Updated') do
        let(:id) { notification.id }
        let(:notification) { { subject: 'Updated Notification', active_flag: true } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }
        let(:notification) { { subject: 'Updated Notification', active_flag: true } }

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

    delete('delete notification') do
      tags 'Notifications'

      response(204, 'Deleted') do
        let(:id) { notification.id }
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }

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

  path '/api/v1/notifications/{id}/toggle_active' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the notification'

    patch('toggle notification visibility') do
      tags 'Notifications'

      response(200, 'Visibility toggled') do
        let(:id) { notification.id }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }

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
