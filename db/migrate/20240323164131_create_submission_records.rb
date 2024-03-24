class CreateSubmissionRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_records do |t|
      t.text :type
      t.string :content
      t.string :operation
      t.integer :team_id
      t.string :user
      t.integer :assignment_id
      t.timestamps null: false
    end
  end
end
