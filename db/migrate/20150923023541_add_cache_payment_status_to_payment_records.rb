class AddCachePaymentStatusToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :cache_payment_status, :string
  end
end
