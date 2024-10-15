class SignUpTopic < ApplicationRecord
  has_many :signed_up_teams, foreign_key: 'topic_id', dependent: :destroy
  has_many :teams, through: :signed_up_teams # list all teams choose this topic, no matter in waitlist or not
  has_many :assignment_questionnaires, class_name: 'AssignmentQuestionnaire', foreign_key: 'topic_id', dependent: :destroy
  has_many :due_dates, class_name: 'DueDate', foreign_key: 'due_date_id', dependent: :destroy, as: :parent
  belongs_to :assignment
end
