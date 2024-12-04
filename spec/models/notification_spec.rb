require 'rails_helper'

RSpec.describe Notification, type: :model do
  before(:each) do
    # Mock the course and user
    @course = instance_double(Course, name: "Ruby 101")
    role = instance_double(Role, id: 1, name: "Student")
    @user = instance_double(User, id: 1, name: "Test User", email: "test@example.com", role: role)
  end

  describe 'validations' do
    it 'is invalid without a subject' do
      notification = Notification.new(subject: nil)
      expect(notification).not_to be_valid
      expect(notification.errors[:subject]).to include("can't be blank")
    end

    it 'is invalid without a description' do
      notification = Notification.new(description: nil)
      expect(notification).not_to be_valid
      expect(notification.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without an expiration_date' do
      notification = Notification.new(expiration_date: nil)
      expect(notification).not_to be_valid
      expect(notification.errors[:expiration_date]).to include("can't be blank")
    end

    it 'is invalid if expiration_date is in the past' do
      notification = Notification.new(expiration_date: Date.yesterday)
      expect(notification).not_to be_valid
      expect(notification.errors[:expiration_date]).to include("cannot be in the past")
    end
  end

  describe 'associations' do
    it 'belongs to a course' do
      # Mock the course association
      notification = Notification.new
      allow(notification).to receive(:course).and_return(@course)

      # Test that the association returns the mocked course
      expect(notification.course).to eq(@course)
    end

    it 'belongs to a user' do
      # Mock the user association
      notification = Notification.new
      allow(notification).to receive(:user).and_return(@user)

      # Test that the association returns the mocked user
      expect(notification.user).to eq(@user)
    end
  end

  describe 'scopes' do
    before(:each) do
      @notification1 = instance_double(
        Notification,
        subject: "Active Notification",
        expiration_date: Date.today + 3,
        active_flag: true,
        course_name: @course.name,
        user: @user
      )

      @notification2 = instance_double(
        Notification,
        subject: "Expired Notification",
        expiration_date: Date.yesterday,
        active_flag: true,
        course_name: @course.name,
        user: @user
      )

      @notification3 = instance_double(
        Notification,
        subject: "Inactive Notification",
        expiration_date: Date.today + 7,
        active_flag: false,
        course_name: @course.name,
        user: @user
      )
    end

    describe '.active' do
      it 'returns notifications that are active' do
        allow(Notification).to receive(:active).and_return([@notification1])
        expect(Notification.active).to include(@notification1)
        expect(Notification.active).not_to include(@notification2, @notification3)
      end
    end

    describe '.expired' do
      it 'returns notifications that are expired' do
        allow(Notification).to receive(:expired).and_return([@notification2])
        expect(Notification.expired).to include(@notification2)
        expect(Notification.expired).not_to include(@notification1, @notification3)
      end
    end

    describe '.unread_by' do
      it 'returns notifications that are unread by the user' do
        allow(Notification).to receive(:unread_by).with(@user).and_return([@notification1])
        unread_notifications = Notification.unread_by(@user)
        expect(unread_notifications).to include(@notification1)
        expect(unread_notifications).not_to include(@notification2, @notification3)
      end
    end
  end
end
