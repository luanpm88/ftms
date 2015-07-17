class AddAccountManagerIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :account_manager_id, :integer
  end
end
