class AddCacheBooksToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_books, :text, index: true
  end
end
