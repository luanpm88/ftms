class CreateContactsSeminars < ActiveRecord::Migration
  def change
    create_table :contacts_seminars do |t|
      t.integer :contact_id
      t.integer :seminar_id

      t.timestamps null: false
    end
  end
end
