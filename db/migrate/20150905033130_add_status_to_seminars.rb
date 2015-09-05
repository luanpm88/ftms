class AddStatusToSeminars < ActiveRecord::Migration
  def change
    add_column :seminars, :status, :text
  end
end
