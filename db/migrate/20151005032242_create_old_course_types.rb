class CreateOldCourseTypes < ActiveRecord::Migration
  def change
    create_table :old_course_types do |t|
      t.text :course_type_id 
      t.text :course_type_name 
      t.text :course_type_short_name 
      t.text :course_discount 
      t.text :course_discount_value 
      t.text :course_inquiry
      
      t.timestamps null: false
    end
  end
end
