class AddVatCodeToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :vat_code, :string
  end
end
