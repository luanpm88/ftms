class AddParentIdToSeminars < ActiveRecord::Migration
  def change
    add_column :seminars, :parent_id, :integer
  end
end
