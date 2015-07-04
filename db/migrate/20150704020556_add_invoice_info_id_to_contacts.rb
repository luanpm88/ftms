class AddInvoiceInfoIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :invoice_info_id, :integer
  end
end
