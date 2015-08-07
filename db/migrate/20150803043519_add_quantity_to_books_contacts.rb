class AddQuantityToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :quantity, :integer
  end
end
