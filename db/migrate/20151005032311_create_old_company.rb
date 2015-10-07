class CreateOldCompany < ActiveRecord::Migration
  def change
    create_table :old_company do |t|
      t.text :company_id 
      t.text :company_name 
      t.text :company_address 
      t.text :company_manager 
      t.text :company_off_phone 
      t.text :company_fax 
      t.text :company_manager_hphone 
      t.text :company_email

      t.timestamps null: false
    end
  end
end
