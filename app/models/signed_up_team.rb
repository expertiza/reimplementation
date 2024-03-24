class SignedUpTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  # the below has been added to make is consistent with the database schema
  validates :topic_id, :team_id, presence: true
  scope :by_team_id, ->(team_id) { where('team_id = ?', team_id) }

  def self.find_team_users(assignment_id, user_id)
    TeamsUser.joins('INNER JOIN teams ON teams_users.team_id = teams.id')
             .select('teams.id as t_id')
             .where('teams.parent_id = ? and teams_users.user_id = ?', assignment_id, user_id)
  end
end