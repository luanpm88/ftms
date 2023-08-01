class AddVisibleToUserLogs < ActiveRecord::Migration
  def change
    add_column :user_logs, :visible, :boolean, default: true
  end
end
