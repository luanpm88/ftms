class AddRemovedContactIdsToRelatedContacts < ActiveRecord::Migration
  def change
    add_column :related_contacts, :removed_contact_ids, :text
  end
end
