class AddAnnouncingUserIdsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :annoucing_user_ids, :text
  end
end
