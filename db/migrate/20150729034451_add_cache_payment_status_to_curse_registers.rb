class AddCachePaymentStatusToCurseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :cache_payment_status, :string
  end
end
