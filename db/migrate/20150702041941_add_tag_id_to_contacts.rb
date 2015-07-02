class AddTagIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :tag_id, :integer
  end
end
