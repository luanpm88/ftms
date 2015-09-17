class AddCourseTypeIdsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :course_type_ids, :text
  end
end
