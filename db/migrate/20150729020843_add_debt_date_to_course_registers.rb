class AddDebtDateToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :debt_date, :datetime
  end
end
