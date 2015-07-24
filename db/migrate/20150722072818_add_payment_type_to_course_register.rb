class AddPaymentTypeToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :payment_type, :string
  end
end
