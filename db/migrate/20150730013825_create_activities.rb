class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id
      t.integer :contact_id
      t.text :note

      t.timestamps null: false
    end
  end
end
