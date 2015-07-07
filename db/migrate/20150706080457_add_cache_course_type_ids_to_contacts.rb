class AddCacheCourseTypeIdsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_course_type_ids, :text
  end
end
