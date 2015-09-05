class AddAnnoucingUserIdsToSeminars < ActiveRecord::Migration
  def change
    add_column :seminars, :annoucing_user_ids, :text
  end
end
