class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :contact_id
      t.integer :user_id
      t.datetime :transfer_date
      t.integer :hours
      t.decimal :money
      t.decimal :admin_fee
      t.integer :transfer_for

      t.timestamps null: false
    end
  end
end
