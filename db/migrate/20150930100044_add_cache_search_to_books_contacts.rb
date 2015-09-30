class AddCacheSearchToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :cache_search, :text
  end
end
