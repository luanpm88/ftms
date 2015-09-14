class AddDeletedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :deleted, :integer, default: 0
  end
end
