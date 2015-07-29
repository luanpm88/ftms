class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :course_register_id
      t.integer :contact_id
      t.datetime :delivery_date
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
