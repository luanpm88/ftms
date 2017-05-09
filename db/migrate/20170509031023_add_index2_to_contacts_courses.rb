class AddIndex2ToContactsCourses < ActiveRecord::Migration
  def change
    add_index :contacts_courses, :contact_id
    add_index :contacts_courses, :course_id
    add_index :contacts_courses, :course_register_id
    add_index :contacts_courses, :full_course
    add_index :contacts_courses, :discount_programs
    add_index :contacts_courses, :cache_payment_status
  end
end
