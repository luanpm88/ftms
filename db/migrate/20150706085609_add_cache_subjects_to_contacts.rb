class AddCacheSubjectsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_subjects, :text
  end
end
