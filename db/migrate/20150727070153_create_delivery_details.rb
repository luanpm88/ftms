class CreateDeliveryDetails < ActiveRecord::Migration
  def change
    create_table :delivery_details do |t|
      t.integer :delivery_id
      t.integer :book_id
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
