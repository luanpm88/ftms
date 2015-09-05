class AddAnnouncingUserIdsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :annoucing_user_ids, :text
  end
end
