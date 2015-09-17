class AddDestinationToStockUpdates < ActiveRecord::Migration
  def change
    add_column :stock_updates, :destination, :text
  end
end
