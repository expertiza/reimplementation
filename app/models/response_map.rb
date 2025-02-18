# frozen_string_literal: true

# The ResponseMap model represents the association between reviewers and reviewees for a specific assignment. 
# In Expertiza, this model allows participants (students) to assess each other’s work, acting as a map or link
# between reviewers (who perform evaluations) and reviewees (who are evaluated).  

class ResponseMap < ApplicationRecord
  # Relationships:
  has_many :response, foreign_key: 'map_id', dependent: :destroy, inverse_of: false
  belongs_to :reviewer, class_name: 'Participant', foreign_key: 'reviewer_id', inverse_of: false
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id', inverse_of: false
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id', inverse_of: false

  # Validations: 
  validates :reviewer_id, presence: true
  validates :reviewee_id, presence: true
  validates :reviewed_object_id, presence: true
  validates :reviewee_id, uniqueness: { scope: [:reviewer_id, :reviewed_object_id], message: 'Duplicate response map is not allowed.' }


  # Delegations:
  delegate :fullname, to: :reviewer, prefix: true, allow_nil: true
  delegate :name, to: :assignment, prefix: true, allow_nil: true

  # Aliases:
  alias map_id id

  # Scopes:
  
  # Scope to find all maps for a specific team by reviewee_id
  scope :for_team, ->(team_id) { where(reviewee_id: team_id) }

  # Scope to find all maps associated with a specific reviewer
  scope :by_reviewer, ->(reviewer_id) { where(reviewer_id: reviewer_id) }

  # Scope to find all maps associated with a specific assignment
  scope :for_assignment, ->(assignment_id) { where(reviewed_object_id: assignment_id) }

  # Scope to get maps that have at least one response
  scope :with_responses, -> { joins(:response).distinct }

  # Scope to retrieve maps with at least one submitted response
  scope :with_submitted_responses, -> { joins(:response).where(responses: { is_submitted: true }).distinct }

  # Basic accessor methods
  # app/models/response_map.rb
  def get_reviewer
    reviewer || raise(ActiveRecord::RecordNotFound, 'Reviewer not found')
  end

  def get_reviewee
    reviewee || raise(ActiveRecord::RecordNotFound, 'Reviewee not found')
  end

  def get_assignment
    assignment || raise(ActiveRecord::RecordNotFound, 'Assignment not found')
  end

  def delete(_force = nil)
    destroy
  end

  def safe_delete
    if response.exists?
      # Return special code if responses are associated
      :cannot_delete
    else
      # Delete the response map if no responses are associated
      destroy
      :deleted
    end
  end

  def survey?
    false
  end


  # Class Methods:
  class << self
    # Retrieves all responses associated with a specific team and sorts them by the reviewer’s fullname.
    def assessments_for(team)
      return [] if team.nil?
      fetch_and_sort_responses(for_team(team.id))
    end

    def latest_responses_for_team_by_reviewer(team, reviewer)
      return [] if team.nil? || reviewer.nil?
      fetch_latest_responses(for_team(team.id).by_reviewer(reviewer.id))
    end

    # Fetches all responses submitted by a specific reviewer
    def responses_by_reviewer(reviewer)
      return [] if reviewer.nil?
      fetch_submitted_responses(by_reviewer(reviewer.id))
    end

    # Retuens only submitted responses from maps.
    def fetch_submitted_responses(maps)
      maps.with_submitted_responses
          .includes(:response)
          .flat_map { |map| map.response.select(&:is_submitted) }
    end

    # Returns all responses associated with assignment.
    def responses_for_assignment(assignment)
      return [] if assignment.nil?
      fetch_submitted_responses(for_assignment(assignment.id))
    end
    
    private

    # Collects and sorts valid responses for the specified maps by reviewer name.
    def fetch_and_sort_responses(maps)
      responses = collect_valid_responses(maps)
      sort_responses_by_reviewer_name(responses)
    end

    # Collects responses from the provided maps, filtering out maps without responses or those with unsubmitted responses.
    def collect_valid_responses(maps)
      maps.includes(:response, reviewer: :user).map do |map|
        next if map.response.empty?

        process_response_by_type(map)
      end.compact
    end

    # Fetches the latest response for a map based on the response type and submission status.
    # For "ReviewResponseMap" types, only submitted responses are considered valid.
    def process_response_by_type(map)
      latest_response = map.response.last
      return nil if latest_response.nil?

      if map.type == 'ReviewResponseMap'
        latest_response if latest_response.is_submitted
      else
        latest_response
      end
    end

    def sort_responses_by_reviewer_name(responses)
      responses.sort_by { |response| response.map.reviewer_fullname.to_s }
    end

    # Collects the latest submitted responses for each map in the specified maps.
    def fetch_latest_responses(maps)
      maps.includes(:response)
          .map { |map| map.response.last }
          .compact
          .select(&:is_submitted)
    end

    # Retrieves only submitted responses.
    def fetch_submitted_responses(maps)
      maps.with_submitted_responses
          .includes(:response)
          .flat_map { |map| map.response.select(&:is_submitted) }
    end
  end

  # Instance Methods:
  # Retrieves the assignment associated with the reviewer's team.
  def response_assignment
    reviewer.assignment
  end

  # Method to return the count of responses associated with this response map
  def response_count
    response.count
  end
end
