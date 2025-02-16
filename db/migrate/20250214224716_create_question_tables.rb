class CreateQuestionTables < ActiveRecord::Migration[7.0]
  def change
    create_table :question_advices, options: "CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
      t.bigint :question_id, null: false
      t.integer :score
      t.text :advice
      t.timestamps
    end
    add_index :question_advices, :question_id, name: "index_question_advices_on_question_id"

    create_table :question_types, options: "CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
      t.string :name
      t.timestamps
    end

    create_table :questionnaire_types, options: "CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
      t.string :name
      t.timestamps
    end

    create_table :quiz_question_choices, id: :integer, options: "CHARSET=latin1" do |t|
      t.integer :question_id
      t.text :txt
      t.boolean :iscorrect, default: false
      t.timestamps
    end

    add_foreign_key :question_advices, :questions
  end
end
