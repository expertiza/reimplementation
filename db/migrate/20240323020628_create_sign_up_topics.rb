class CreateSignUpTopics < ActiveRecord::Migration[7.0]
  def change
    create_table :sign_up_topics do |t|
      t.text :topic_name, null: false
      t.integer :max_choosers, default: 0, null: false
      t.text :category
      t.string :topic_identifier, limit: 10
      t.integer :micropayment, default: 0
      t.integer :private_to
      t.text :description
      t.string :link
    end
    add_reference :sign_up_topics, :assignments, foreign_key: true, null: false
  end
end
