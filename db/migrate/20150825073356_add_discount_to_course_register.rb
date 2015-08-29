class AddDiscountToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :discount, :decimal
  end
end
