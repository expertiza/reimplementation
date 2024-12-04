# spec/requests/api/v1/courses_spec.rb
require 'rails_helper'

RSpec.describe 'Courses API', type: :request do
  let(:super_admin) { create(:user, role: Role::SUPER_ADMINISTRATOR) }
  let(:course_params) { { name: 'Sample Course', directory_path: 'sample', instructor_id: instructor.id, institution_id: 1 } }

  describe 'POST /courses' do
    context 'as a super administrator' do
      it 'creates a course successfully' do
        sign_in super_admin
        post '/api/v1/courses', params: { course: course_params }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'DELETE /courses/:id' do
    let!(:course) { create(:course, instructor:) }

    context 'as a super administrator' do
      it 'deletes the course successfully' do
        sign_in super_admin
        delete "/api/v1/courses/#{course.id}"
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end