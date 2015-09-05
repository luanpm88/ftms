class AddParentIdToCourseTypes < ActiveRecord::Migration
  def change
    add_column :course_types, :parent_id, :integer
  end
end
