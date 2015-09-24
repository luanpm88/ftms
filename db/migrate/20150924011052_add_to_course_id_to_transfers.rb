class AddToCourseIdToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :to_course_id, :integer
  end
end
