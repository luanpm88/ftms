class AddAnnoucingUserIdsToCourseTypes < ActiveRecord::Migration
  def change
    add_column :course_types, :annoucing_user_ids, :text
  end
end
