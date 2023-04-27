class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string "question_text"
      t.string "correct_option"
      t.string "option1"
      t.string "option2"
      t.string "option3"
      t.string "option4"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
  end
end
end
