class AddBasePasswordToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :base_password, :string
  end
end
