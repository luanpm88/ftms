class AddDisplayOrderToStockTypes < ActiveRecord::Migration
  def change
    add_column :stock_types, :display_order, :integer
  end
end
