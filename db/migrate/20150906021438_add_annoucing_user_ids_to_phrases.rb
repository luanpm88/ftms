class AddAnnoucingUserIdsToPhrases < ActiveRecord::Migration
  def change
    add_column :phrases, :annoucing_user_ids, :text
  end
end
