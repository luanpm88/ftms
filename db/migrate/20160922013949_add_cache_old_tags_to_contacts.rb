class AddCacheOldTagsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_old_tags, :text
  end
end
