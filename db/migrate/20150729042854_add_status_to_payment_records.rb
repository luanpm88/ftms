class AddStatusToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :status, :integer
  end
end
