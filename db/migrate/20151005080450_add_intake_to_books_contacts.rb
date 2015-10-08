class AddIntakeToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :intake, :datetime
  end
end
