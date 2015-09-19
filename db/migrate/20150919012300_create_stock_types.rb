class CreateStockTypes < ActiveRecord::Migration
  def change
    create_table :stock_types do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.text :annoucing_user_ids
      t.integer :parent_id
      t.string :status
      t.integer :parent_id

      t.timestamps null: false
    end
  end
end
