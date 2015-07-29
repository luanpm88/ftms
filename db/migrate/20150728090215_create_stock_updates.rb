class CreateStockUpdates < ActiveRecord::Migration
  def change
    create_table :stock_updates do |t|
      t.string :type_name
      t.integer :book_id
      t.integer :quantity
      t.datetime :created_date
      t.integer :user_id
      t.text :note

      t.timestamps null: false
    end
  end
end
