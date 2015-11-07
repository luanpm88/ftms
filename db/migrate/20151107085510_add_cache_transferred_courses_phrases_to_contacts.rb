class AddCacheTransferredCoursesPhrasesToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :cache_transferred_courses_phrases, :text
  end
end
