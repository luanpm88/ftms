class AddCourseIdToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :course_id, :integer
  end
end
