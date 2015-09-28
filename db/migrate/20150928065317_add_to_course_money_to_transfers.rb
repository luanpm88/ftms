class AddToCourseMoneyToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :to_course_money, :decimal
  end
end
