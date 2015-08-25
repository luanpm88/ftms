class AddTransferToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :transfer, :decimal
  end
end
