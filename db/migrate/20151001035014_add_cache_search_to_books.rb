class AddCacheSearchToBooks < ActiveRecord::Migration
  def change
    add_column :books, :cache_search, :text
  end
end
