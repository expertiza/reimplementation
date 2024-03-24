class CreateTeamsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :teams_users do |t|
      t.string :pair_programming_status, limit: 1
    end
    add_reference :teams_users, :duty, foreign_key: { to_table: :duties }
    add_reference :teams_users, :teams, foreign_key: true
    add_reference :teams_users, :users, foreign_key: true
    add_reference :teams_users, :participants, foreign_key: true
  end
end
