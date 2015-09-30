class AddCacheCoursesToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_courses, :text
  end
end
