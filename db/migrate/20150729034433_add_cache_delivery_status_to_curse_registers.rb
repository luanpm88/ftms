class AddCacheDeliveryStatusToCurseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :cache_delivery_status, :string
  end
end
