class AddCourseTypeIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :course_type_id, :integer
  end
end