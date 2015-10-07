class CreateOldNoteDetails < ActiveRecord::Migration
  def change
    create_table :old_note_details do |t|
   	  t.text :note_id 
      t.text :student_id 
      t.text :cus_id 
      t.datetime :note_date 
      t.text :note_detail 
      t.text :priority 
      t.text :staff

      t.timestamps null: false
    end
  end
end
