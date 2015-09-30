class AddCacheSearchToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :cache_search, :text
  end
end
