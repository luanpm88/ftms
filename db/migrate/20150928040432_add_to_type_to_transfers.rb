class AddToTypeToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :to_type, :string
  end
end
