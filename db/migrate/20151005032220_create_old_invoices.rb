class CreateOldInvoices < ActiveRecord::Migration
  def change
    create_table :old_invoices do |t|
      t.text :invoice_id 
      t.text :student_id 
      t.text :paid 
      t.text :count_for

      t.timestamps null: false
    end
  end
end
