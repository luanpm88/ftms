class AddCacheDeliveryStatusToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :cache_delivery_status, :text
  end
end
