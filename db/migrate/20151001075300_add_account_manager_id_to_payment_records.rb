class AddAccountManagerIdToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :account_manager_id, :integer
  end
end
