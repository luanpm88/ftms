class AddPaymentTypeToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :payment_type, :string
  end
end
