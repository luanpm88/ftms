class AddInvoiceRequiredToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :invoice_required, :boolean, default: false
  end
end
