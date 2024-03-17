class CreateDuties < ActiveRecord::Migration[7.0]
  def change
    create_table :duties do |t|
      t.string :name
      t.integer :max_members_for_duty
      t.references :assignment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
