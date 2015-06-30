class AddFirstNameToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :first_name, :string
  end
end
