class CreateDiscountPrograms < ActiveRecord::Migration
  def change
    create_table :discount_programs do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.datetime :start_at
      t.datetime :end_at
      t.decimal :rate

      t.timestamps null: false
    end
  end
end
