class AddParentIdToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :parent_id, :integer
  end
end
