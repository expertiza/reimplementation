class CreateDuties < ActiveRecord::Migration[7.0]
  def change
    create_table :duties do |t|
      t.string :name
      t.integer :max_members_for_duty
      t.timestamps null: false
    end
    add_reference :duties, :assignments, foreign_key: true
  end
end
