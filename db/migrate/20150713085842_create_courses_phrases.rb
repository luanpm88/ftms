class CreateCoursesPhrases < ActiveRecord::Migration
  def change
    create_table :courses_phrases do |t|
      t.integer :course_id
      t.integer :phrase_id
      t.datetime :start_at

      t.timestamps null: false
    end
  end
end
