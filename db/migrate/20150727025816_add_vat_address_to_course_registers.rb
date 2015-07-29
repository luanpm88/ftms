class AddVatAddressToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :vat_address, :string
  end
end
