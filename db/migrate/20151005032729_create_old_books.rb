class CreateOldBooks < ActiveRecord::Migration
  def change
    create_table :old_books do |t|
      t.text :book_id 
      t.text :subject_id 
      t.text :book_type 
      t.text :book_vol 
      t.text :amount 
      t.text :delivered 
      t.text :need_delivery 
      t.text :in_stock 
      t.text :need_ordering 
      t.text :remark 
      t.text :remark1

      t.timestamps null: false
    end
  end
end
