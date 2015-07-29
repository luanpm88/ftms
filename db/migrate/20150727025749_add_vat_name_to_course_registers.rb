class AddVatNameToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :vat_name, :string
  end
end
