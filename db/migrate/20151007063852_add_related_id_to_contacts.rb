class AddRelatedIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :related_id, :integer
  end
end
