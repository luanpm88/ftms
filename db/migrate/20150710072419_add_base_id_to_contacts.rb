class AddBaseIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :base_id, :string
  end
end
