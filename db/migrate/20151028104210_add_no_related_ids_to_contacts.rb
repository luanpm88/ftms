class AddNoRelatedIdsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :no_related_ids, :text
  end
end
