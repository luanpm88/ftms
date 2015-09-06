class AddStatusToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :status, :text
  end
end
