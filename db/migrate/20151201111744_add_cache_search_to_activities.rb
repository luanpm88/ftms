class AddCacheSearchToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :cache_search, :text
  end
end
