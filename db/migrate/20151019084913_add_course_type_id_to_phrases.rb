class AddCourseTypeIdToPhrases < ActiveRecord::Migration
  def change
    add_column :phrases, :course_type_id, :integer
  end
end
