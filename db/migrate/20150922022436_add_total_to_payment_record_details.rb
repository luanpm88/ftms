class AddTotalToPaymentRecordDetails < ActiveRecord::Migration
  def change
    add_column :payment_record_details, :total, :decimal
  end
end
