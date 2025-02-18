class LatePolicy < ApplicationRecord
  belongs_to :user

  has_many :assignments, dependent: :nullify

  validates :policy_name, presence: true, format: { with: /\A[A-Za-z0-9][A-Za-z0-9\s'._-]+\z/i }
  validates :instructor_id, presence: true
  validates :max_penalty, presence: true, numericality: { greater_than: 0, less than: 100 }
  validates :penalty_per_unit, presence: true, numericality: { greater_than: 0 }
  validates :penalty_unit, presence: true

  def duplicate_name_check(instructor_id, current_policy_id = nil)
    existing_policy = LatePolicy.find_by(policy_name: self.policy_name, instructor_id: instructor_id)

    if existing_policy && (current_policy_id.nil? || existing_policy.id != current_policy_id)
      error_message = "A policy with the same name #{self.policy_name} already exists."
      return false, error_message
    end

    return true, nil
  end

  def self.update_calculated_penalty_objects(late_policy)
    CalculatedPenalty.find_each do |pen|
      participant = AssignmentParticipant.find(pen.participant_id)
      assignment = participant.assignment
      next unless assignment.late_policy_id == late_policy.id

      penalties = calculate_penalty(pen.participant_id)
      total_penalty = penalties.values.sum
      case pen.deadline_type_id.to_i
      when 1
        pen.update(penalty_points: penalties[:submission])
      when 2
        pen.update(penalty_points: penalties[:review])
      when 5
        pen.update(penalty_points: penalties[:meta_review])
      end
    end
  end
end
