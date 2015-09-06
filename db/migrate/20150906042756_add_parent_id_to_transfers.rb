class AddParentIdToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :parent_id, :integer
  end
end
