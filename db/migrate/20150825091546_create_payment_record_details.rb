class CreatePaymentRecordDetails < ActiveRecord::Migration
  def change
    create_table :payment_record_details do |t|
      t.integer :contacts_course_id
      t.decimal :books_contact_id
      t.decimal :amount
      t.integer :payment_record_id

      t.timestamps null: false
    end
  end
end
