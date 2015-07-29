class AddInvoiceRequiredToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :invoice_required, :boolean
  end
end
