class CreateBookPrices < ActiveRecord::Migration
  def change
    create_table :book_prices do |t|
      t.integer :book_id
      t.text :prices
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
