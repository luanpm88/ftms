class CreateRelatedContacts < ActiveRecord::Migration
  def change
    create_table :related_contacts do |t|
      t.text :contact_ids

      t.timestamps null: false
    end
  end
end
