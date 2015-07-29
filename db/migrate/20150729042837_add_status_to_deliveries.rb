class AddStatusToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :status, :integer
  end
end
