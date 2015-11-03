class AddOldStudentCourseTypeIdsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :old_student_course_type_ids, :text
  end
end
