class AddCacheLastDateToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :cache_last_date, :date
  end
end
