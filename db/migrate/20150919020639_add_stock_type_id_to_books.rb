class AddStockTypeIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :stock_type_id, :integer
  end
end
