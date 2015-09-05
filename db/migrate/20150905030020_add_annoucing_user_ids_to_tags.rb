class AddAnnoucingUserIdsToTags < ActiveRecord::Migration
  def change
    add_column :contact_tags, :annoucing_user_ids, :text
  end
end
