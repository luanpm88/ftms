class AddUpfrontToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :upfront, :boolean, default: false
  end
end
