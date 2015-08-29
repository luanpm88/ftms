class AddBankRefToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :bank_ref, :string
  end
end
