class AddParentIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :parent_id, :integer
  end
end
