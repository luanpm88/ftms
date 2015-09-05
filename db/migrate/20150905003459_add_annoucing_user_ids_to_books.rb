class AddAnnoucingUserIdsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :annoucing_user_ids, :text
  end
end
