class AddDescriptionToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :description, :text
  end
end
