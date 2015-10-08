class CreateOldSubjects < ActiveRecord::Migration
  def change
    create_table :old_subjects do |t|
      t.text :subject_id
      t.text :course_id
      t.text :subject_name
      t.text :subject_lecturer
      t.text :start_date
      t.text :end_date
      t.text :belong_to
      t.text :subject_phrase

      t.timestamps null: false
    end
  end
end
