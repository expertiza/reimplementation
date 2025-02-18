# spec/models/response_map_spec.rb
require 'rails_helper'

RSpec.describe ResponseMap, type: :model do
  # Set up roles that will be assigned to instructor and participant users
  let!(:role_instructor) { Role.create!(name: 'Instructor') }
  let!(:role_participant) { Role.create!(name: 'Participant') }

  # Set up instructor, assignment, and participant records for testing associations
  let(:instructor) { Instructor.create!(role: role_instructor, name: 'Instructor Name', full_name: 'Full Instructor Name', email: 'instructor@example.com', password: 'password') }
  let(:assignment) { Assignment.create!(name: 'Test Assignment', instructor: instructor) }
  let(:user) { User.create!(role: role_participant, name: 'no name', full_name: 'no one', email: 'user@example.com', password: 'password') }
  let(:participant) { Participant.create!(user: user, assignment: assignment) }
  let(:participant) { Participant.create!(user: user, assignment: assignment, team: team) }
  let(:response_map) { ResponseMap.includes(reviewee: [:user, :team]).create!(assignment: assignment, reviewee: participant, reviewer: participant) }
  let(:team) { Team.create!(assignment: assignment) }
  let(:response_map) { ResponseMap.create!(assignment: assignment, reviewee: participant, reviewer: participant) }
  let(:response_map) { ResponseMap.includes(reviewer: :user, reviewee: [:user, :team], assignment: :rubric).create!(assignment: assignment, reviewee: participant, reviewer: participant) }


  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(response_map).to be_valid
    end

    it 'is not valid without a reviewer_id' do
      response_map.reviewer_id = nil
      expect(response_map).not_to be_valid
      expect(response_map.errors[:reviewer_id]).to include("can't be blank")
    end

    it 'is not valid without a reviewee_id' do
      response_map.reviewee_id = nil
      expect(response_map).not_to be_valid
      expect(response_map.errors[:reviewee_id]).to include("can't be blank")
    end

    it 'is not valid without a reviewed_object_id' do
      response_map.reviewed_object_id = nil
      expect(response_map).not_to be_valid
      expect(response_map.errors[:reviewed_object_id]).to include("can't be blank")
    end

    it 'is not valid with an invalid reviewer_id' do
      response_map.reviewer_id = 'invalid_id'
      expect(response_map).not_to be_valid
    end

    it 'is not valid with an invalid reviewee_id' do
      response_map.reviewee_id = 'invalid_id'
      expect(response_map).not_to be_valid
    end

    it 'is not valid with an invalid reviewed_object_id' do
      response_map.reviewed_object_id = 'invalid_id'
      expect(response_map).not_to be_valid
    end

    it 'does not allow duplicate response maps with the same reviewee, reviewer, and reviewed_object' do
      # Using the same participant as both reviewer and reviewee
      ResponseMap.create(assignment: assignment, reviewee: participant, reviewer: participant)
  
      duplicate_response_map = ResponseMap.new(
        assignment: assignment,
        reviewee: participant,
        reviewer: participant
      )
      
      expect(duplicate_response_map).not_to be_valid
      expect(duplicate_response_map.errors[:reviewee_id]).to include("Duplicate response map is not allowed.")
    end
  end

  describe 'scopes' do
    let(:submitted_response) { Response.create!(map_id: response_map.id, response_map: response_map, is_submitted: true) }

    it 'retrieves response maps for a specified team' do
      expect(ResponseMap.for_team(participant.id)).to include(response_map)
    end

    it 'retrieves response maps by reviewer' do
      expect(ResponseMap.by_reviewer(participant.id)).to include(response_map)
    end

    it 'retrieves response maps for a specified assignment' do
      expect(ResponseMap.for_assignment(assignment.id)).to include(response_map)
    end

    it 'retrieves response maps with responses' do
      submitted_response
      expect(ResponseMap.with_responses).to include(response_map)
    end

    it 'retrieves response maps with submitted responses' do
      submitted_response
      expect(ResponseMap.with_submitted_responses).to include(response_map)
    end

    it 'does not include response maps without responses in with_responses' do
      expect(ResponseMap.with_responses).not_to include(response_map)
    end
  end

  #Tests for accessor methods
  describe 'accessor methods' do
    describe '#get_reviewer' do
      it 'returns reviewer with included user information' do
        reviewer = response_map.get_reviewer
        expect(reviewer).to eq(participant)
        expect(reviewer.user).to eq(user)
      end

      it 'includes user association' do
        reviewer = response_map.get_reviewer
        expect(reviewer.association(:user)).to be_loaded
      end
    end

    describe '#get_reviewee' do
      it 'returns reviewee with included user and team information' do
        reviewee = response_map.get_reviewee
        expect(reviewee).to eq(participant)
        expect(reviewee.user).to eq(user)
      end

      it 'includes user and team associations' do
        reviewee = response_map.get_reviewee
        expect(reviewee.association(:user)).to be_loaded
        expect(reviewee.association(:team)).to be_loaded
      end

      context 'when reviewee belongs to a team' do
        before do
          participant.update(team: team)
        end

        it 'includes team information' do
          reviewee = response_map.get_reviewee
          expect(reviewee.team).to eq(team)
        end
      end
    end

    describe '#get_assignment' do
      it 'returns the correct assignment' do
        assignment_result = response_map.get_assignment
        expect(assignment_result).to eq(assignment)
      end
    end

    describe 'error handling when associations are missing' do
      let(:orphaned_response_map) { ResponseMap.new }

      it 'handles missing reviewer gracefully' do
        expect { orphaned_response_map.get_reviewer }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'handles missing reviewee gracefully' do
        expect { orphaned_response_map.get_reviewee }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'handles missing assignment gracefully' do
        expect { orphaned_response_map.get_assignment }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #Test for safe delete method
  describe '#safe_delete' do
  context 'when there are no associated responses' do
    it 'deletes the response map and returns :deleted' do
      # Call the safe_delete method
      result = response_map.safe_delete

      # Expect the result to be :deleted
      expect(result).to eq(:deleted)

      # Confirm the response_map has been deleted
      expect(ResponseMap.find_by(id: response_map.id)).to be_nil
    end
  end

  context 'when there are associated responses' do
    before do
      # Create a response associated with the response_map
      Response.create!(map_id: response_map.id, is_submitted: true)
    end

    it 'does not delete the response map and returns :cannot_delete' do
      # Call the safe_delete method
      result = response_map.safe_delete

      # Expect the result to be :cannot_delete
      expect(result).to eq(:cannot_delete)

      # Confirm the response_map has not been deleted
      expect(ResponseMap.find_by(id: response_map.id)).not_to be_nil
    end
  end
  end

  describe '.assessments_for' do
    it 'returns responses sorted by reviewer name for a valid team' do
      sorted_responses = ResponseMap.assessments_for(participant)
      expect(sorted_responses.map(&:reviewer_fullname)).to eq(sorted_responses.map(&:reviewer_fullname).sort)
    end

    it 'returns an empty array if team is nil' do
      expect(ResponseMap.assessments_for(nil)).to eq([])
    end
  end

  describe '.latest_responses_for_team_by_reviewer' do
    it 'returns only the latest response when multiple responses exist' do
      older_response = Response.create!(map_id: response_map.id, response_map: response_map, is_submitted: true, created_at: 1.day.ago)
      latest_response = Response.create!(map_id: response_map.id, response_map: response_map, is_submitted: true)
      expect(ResponseMap.latest_responses_for_team_by_reviewer(participant, participant)).to include(latest_response)
      expect(ResponseMap.latest_responses_for_team_by_reviewer(participant, participant)).not_to include(older_response)
    end

    it 'returns an empty array if team or reviewer is nil' do
      expect(ResponseMap.latest_responses_for_team_by_reviewer(nil, participant)).to eq([])
      expect(ResponseMap.latest_responses_for_team_by_reviewer(participant, nil)).to eq([])
    end
  end

  describe '.responses_by_reviewer' do
    it 'returns submitted responses by reviewer' do
      response = Response.create!(map_id:response_map.id, response_map: response_map, is_submitted: true)
      expect(ResponseMap.responses_by_reviewer(participant)).to include(response)
    end

    it 'returns an empty array if reviewer is nil' do
      expect(ResponseMap.responses_by_reviewer(nil)).to eq([])
    end
  end

  describe '.responses_for_assignment' do
    it 'returns submitted responses for the specified assignment' do
      response = Response.create!(map_id: response_map.id, response_map: response_map, is_submitted: true)
      expect(ResponseMap.responses_for_assignment(assignment)).to include(response)
    end

    it 'returns an empty array if assignment is nil' do
      expect(ResponseMap.responses_for_assignment(nil)).to eq([])
    end
  end

  describe '#response_assignment' do
    it 'returns the assignment associated with the reviewer’s team' do
      expect(response_map.response_assignment).to eq(participant.assignment)
    end
  end

  describe '#response_count' do
    it 'returns the correct count of associated responses' do
      Response.create!(map_id: response_map.id, response_map: response_map, is_submitted: true)
      Response.create!(map_id: response_map.id, response_map: response_map, is_submitted: true)
      expect(response_map.response_count).to eq(2)
    end
  end
end
