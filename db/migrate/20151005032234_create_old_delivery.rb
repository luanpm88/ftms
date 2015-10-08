class CreateOldDelivery < ActiveRecord::Migration
  def change
    create_table :old_delivery do |t|
      t.text :delivery_id 
      t.text :student_id 
      t.text :subject_id 
      t.text :book_type 
      t.text :book_vol 
      t.text :delivery_yes

      t.timestamps null: false
    end
  end
end
