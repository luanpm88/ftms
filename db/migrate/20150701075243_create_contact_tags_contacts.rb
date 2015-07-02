class CreateContactTagsContacts < ActiveRecord::Migration
  def change
    create_table :contact_tags_contacts do |t|
      t.integer :contact_id
      t.integer :contact_tag_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
