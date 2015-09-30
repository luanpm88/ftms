class AddCacheSearchToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :cache_search, :text
  end
end
