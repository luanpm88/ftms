class AddAmountToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :amount, :decimal
  end
end
