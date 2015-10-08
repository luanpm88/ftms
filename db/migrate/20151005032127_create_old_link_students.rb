class CreateOldLinkStudents < ActiveRecord::Migration
  def change
    create_table :old_link_students do |t|
      t.text :link_student_id
      t.text :subject_id 
      t.text :student_id 
      t.text :subject_array 
      t.text :company_id 
      t.text :paid 
      t.text :count_for 
      t.text :defferal

      t.timestamps null: false
    end
  end
end
