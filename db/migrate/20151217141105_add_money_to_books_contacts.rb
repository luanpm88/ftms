class AddMoneyToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :money, :decimal
  end
end
