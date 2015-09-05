class AddParentIdToTags < ActiveRecord::Migration
  def change
    add_column :contact_tags, :parent_id, :integer
  end
end
