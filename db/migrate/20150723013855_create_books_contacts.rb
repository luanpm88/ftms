class CreateBooksContacts < ActiveRecord::Migration
  def change
    create_table :books_contacts do |t|
      t.integer :course_register_id
      t.integer :book_id
      t.integer :contact_id
      t.decimal :price
      t.integer :discount_program_id
      t.decimal :discount
      t.text :volumn_ids

      t.timestamps null: false
    end
  end
end
