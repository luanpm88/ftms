class AddTransferHourToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :transfer_hour, :decimal
  end
end
