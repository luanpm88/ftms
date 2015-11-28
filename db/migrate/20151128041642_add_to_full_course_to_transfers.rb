class AddToFullCourseToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :to_full_course, :boolean
  end
end
