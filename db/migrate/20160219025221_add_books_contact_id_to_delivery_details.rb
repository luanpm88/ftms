class AddBooksContactIdToDeliveryDetails < ActiveRecord::Migration
  def change
    add_column :delivery_details, :books_contact_id, :integer
  end
end
