class CreateCoursePrices < ActiveRecord::Migration
  def change
    create_table :course_prices do |t|
      t.integer :course_id
      t.text :prices
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
