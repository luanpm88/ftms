class AddToCourseHourToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :to_course_hour, :decimal
  end
end
