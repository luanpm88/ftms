class AddCacheSearchToRelatedContacts < ActiveRecord::Migration
  def change
    add_column :related_contacts, :cache_search, :text
  end
end
