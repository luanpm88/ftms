class AddCacheSearchToStockUpdates < ActiveRecord::Migration
  def change
    add_column :stock_updates, :cache_search, :text
  end
end
