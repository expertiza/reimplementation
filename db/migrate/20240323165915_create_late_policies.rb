class CreateLatePolicies < ActiveRecord::Migration[7.0]
  def change
    create_table :late_policies do |t|
      t.float :penalty_per_unit, limit: 24
      t.integer :max_penalty, default: 0, null: false
      t.string :penalty_unit, null: false
      t.integer :times_used, default: 0, null: false
      t.string :policy_name, null: false
      t.boolean :private, default: true, null: false
    end
  end
end
