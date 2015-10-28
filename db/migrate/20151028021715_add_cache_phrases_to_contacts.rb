class AddCachePhrasesToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_phrases, :text
  end
end
