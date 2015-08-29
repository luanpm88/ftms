class RemoveAmountFromPaymentRecords < ActiveRecord::Migration
  def change
    remove_column :payment_records, :amount, :decimal
  end
end
