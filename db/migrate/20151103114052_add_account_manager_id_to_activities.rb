class AddAccountManagerIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :account_manager_id, :integer
  end
end
