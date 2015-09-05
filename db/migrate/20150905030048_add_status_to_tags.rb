class AddStatusToTags < ActiveRecord::Migration
  def change
    add_column :contact_tags, :status, :text
  end
end
