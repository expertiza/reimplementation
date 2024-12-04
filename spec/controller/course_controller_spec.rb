require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  let(:institution) { create(:institution) }
  let(:admin) { create(:user, role: :admin) }
  let(:instructor) { create(:user, role: :instructor) }
  let(:ta) { create(:user, role: :teaching_assistant) }
  let(:student) { create(:user, role: :student) }
  let(:course) { create(:course, instructor: instructor, institution: institution) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe 'GET #index' do
    context 'when the user is an admin' do
      let(:current_user) { admin }

      it 'returns a list of all courses' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(assigns(:courses)).to include(course)
      end
    end

    context 'when the user is an instructor' do
      let(:current_user) { instructor }

      it 'returns a list of courses for the instructor' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(assigns(:courses)).to include(course)
      end
    end

    context 'when the user is a TA' do
      let(:current_user) { ta }

      it 'returns an unauthorized response' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the user is a student' do
      let(:current_user) { student }

      it 'returns an unauthorized response' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #show' do
    context 'when the user is an admin' do
      let(:current_user) { admin }

      it 'returns the details of the course' do
        get :show, params: { id: course.id }
        expect(response).to have_http_status(:ok)
        expect(assigns(:course)).to eq(course)
      end
    end

    context 'when the user is the course instructor' do
      let(:current_user) { instructor }

      it 'returns the details of the course' do
        get :show, params: { id: course.id }
        expect(response).to have_http_status(:ok)
        expect(assigns(:course)).to eq(course)
      end
    end

    context 'when the user is a TA' do
      let(:current_user) { ta }

      it 'returns an unauthorized response' do
        get :show, params: { id: course.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the user is a student' do
      let(:current_user) { student }

      it 'returns an unauthorized response' do
        get :show, params: { id: course.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #create' do
    let(:course_params) do
      {
        name: 'New Course',
        directory_path: 'new_course',
        instructor_id: instructor.id,
        institution_id: institution.id
      }
    end

    context 'when the user is an admin' do
      let(:current_user) { admin }

      it 'creates a new course' do
        expect {
          post :create, params: { course: course_params }
        }.to change(Course, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the user is an instructor' do
      let(:current_user) { instructor }

      it 'creates a new course' do
        expect {
          post :create, params: { course: course_params }
        }.to change(Course, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the user is a TA' do
      let(:current_user) { ta }

      it 'returns an unauthorized response' do
        post :create, params: { course: course_params }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the user is a student' do
      let(:current_user) { student }

      it 'returns an unauthorized response' do
        post :create, params: { course: course_params }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is an admin' do
      let(:current_user) { admin }

      it 'deletes the course' do
        delete :destroy, params: { id: course.id }
        expect(response).to have_http_status(:no_content)
        expect(Course.exists?(course.id)).to be_falsey
      end
    end

    context 'when the user is the course instructor' do
      let(:current_user) { instructor }

      it 'deletes the course' do
        delete :destroy, params: { id: course.id }
        expect(response).to have_http_status(:no_content)
        expect(Course.exists?(course.id)).to be_falsey
      end
    end

    context 'when the user is a TA' do
      let(:current_user) { ta }

      it 'returns an unauthorized response' do
        delete :destroy, params: { id: course.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the user is a student' do
      let(:current_user) { student }

      it 'returns an unauthorized response' do
        delete :destroy, params: { id: course.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
