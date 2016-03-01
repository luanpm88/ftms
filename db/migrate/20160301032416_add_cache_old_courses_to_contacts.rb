class AddCacheOldCoursesToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_old_courses, :text
  end
end
