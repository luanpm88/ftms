class AddCacheSearchToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :cache_search, :text
  end
end
