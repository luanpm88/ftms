class CreateContactTags < ActiveRecord::Migration
  def change
    create_table :contact_tags do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
