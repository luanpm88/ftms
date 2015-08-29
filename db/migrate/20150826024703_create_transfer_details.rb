class CreateTransferDetails < ActiveRecord::Migration
  def change
    create_table :transfer_details do |t|
      t.integer :transfer_id
      t.integer :contacts_course_id
      t.text :courses_phrase_ids

      t.timestamps null: false
    end
  end
end
