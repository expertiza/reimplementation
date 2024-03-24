class CreateSignedUpTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :signed_up_teams do |t|
      t.integer :team_id, default: 0, null: false
      t.boolean :is_waitlisted, default: false, null: false
      t.integer :preference_priority_number
    end
    add_reference :signed_up_teams, :topic, foreign_key: { to_table: :sign_up_topics }, null: false
  end
end
