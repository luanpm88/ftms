class CreateOldCourses < ActiveRecord::Migration
  def change
    create_table :old_courses do |t|
      t.text :course_id 
      t.text :course_name 
      t.text :order

      t.timestamps null: false
    end
  end
end
