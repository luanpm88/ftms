class AddCacheGroupIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_group_id, :integer
  end
end
