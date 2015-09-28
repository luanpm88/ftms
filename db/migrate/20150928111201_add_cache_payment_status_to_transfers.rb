class AddCachePaymentStatusToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :cache_payment_status, :text
  end
end
