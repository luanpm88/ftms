class AddFullCourseToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :full_course, :boolean
  end
end
