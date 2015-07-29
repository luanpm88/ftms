class CreatePaymentRecords < ActiveRecord::Migration
  def change
    create_table :payment_records do |t|
      t.integer :course_register_id
      t.decimal :amount
      t.datetime :debt_date
      t.integer :bank_account_id
      t.integer :user_id
      t.text :note
      t.datetime :payment_date

      t.timestamps null: false
    end
  end
end
