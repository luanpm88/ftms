class AddEndAtToContactTags < ActiveRecord::Migration
  def change
    add_column :contact_tags, :end_at, :datetime
  end
end
