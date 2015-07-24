class AddDiscountProgramIdToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :discount_program_id, :integer
  end
end
