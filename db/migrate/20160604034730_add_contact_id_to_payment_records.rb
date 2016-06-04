class AddContactIdToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :contact_id, :integer
  end
end
