class AddFullCourseToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :full_course, :boolean
  end
end
