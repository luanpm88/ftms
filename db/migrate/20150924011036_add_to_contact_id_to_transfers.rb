class AddToContactIdToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :to_contact_id, :integer
  end
end
