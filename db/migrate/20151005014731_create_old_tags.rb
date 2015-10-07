class CreateOldTags < ActiveRecord::Migration
  def change
    create_table :old_tags do |t|

      t.text :tag_id
      t.text :student_id
      t.text :tag_name

      t.timestamps null: false
    end
  end
end
