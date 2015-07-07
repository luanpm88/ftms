class CreateCourseTypesSubjects < ActiveRecord::Migration
  def change
    create_table :course_types_subjects do |t|
      t.integer :course_type_id
      t.integer :subject_id

      t.timestamps null: false
    end
  end
end
