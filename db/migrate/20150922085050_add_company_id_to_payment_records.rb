class AddCompanyIdToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :company_id, :integer
  end
end
