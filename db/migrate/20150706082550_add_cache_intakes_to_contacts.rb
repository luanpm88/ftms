class AddCacheIntakesToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_intakes, :text
  end
end
