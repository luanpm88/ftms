class AddCourseTypeIdToSeminars < ActiveRecord::Migration
  def change
    add_column :seminars, :course_type_id, :integer
  end
end
