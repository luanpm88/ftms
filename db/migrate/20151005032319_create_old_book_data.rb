class CreateOldBookData < ActiveRecord::Migration
  def change
    create_table :old_book_data do |t|
      t.text :book_data_id 
      t.text :book_data_name 
      t.text :book_data_array

      t.timestamps null: false
    end
  end
end
