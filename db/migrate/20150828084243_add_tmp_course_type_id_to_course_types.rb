class AddTmpCourseTypeIdToCourseTypes < ActiveRecord::Migration
  def change
    add_column :course_types, :tmp_CourseTypeID, :text
  end
end
