class AddUserIdToTags < ActiveRecord::Migration
  def change
    add_column :contact_tags, :user_id, :integer
  end
end
