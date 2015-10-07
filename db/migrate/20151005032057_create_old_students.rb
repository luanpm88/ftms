class CreateOldStudents < ActiveRecord::Migration
  def change
    create_table :old_students do |t|
      t.text :student_id 
      t.text :consultant_id 
      t.text :student_name 
      t.text :student_title 
      t.datetime :student_birth 
      t.text :student_acca_no 
      t.text :student_company 
      t.text :student_vat_code 
      t.text :student_office 
      t.text :student_location 
      t.text :student_home_add 
      t.text :student_preffer_mailing 
      t.text :student_email_1 
      t.text :student_email_2 
      t.text :student_off_phone 
      t.text :student_hand_phone 
      t.text :student_fax 
      t.text :student_type 
      t.text :student_tags 
      t.text :student_home_phone

      t.timestamps null: false
    end
  end
end
