class CreateSeminars < ActiveRecord::Migration
  def change
    create_table :seminars do |t|
      t.string :name
      t.text :description
      t.datetime :start_at
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
