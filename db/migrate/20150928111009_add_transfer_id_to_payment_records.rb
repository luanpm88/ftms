class AddTransferIdToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :transfer_id, :integer
  end
end
