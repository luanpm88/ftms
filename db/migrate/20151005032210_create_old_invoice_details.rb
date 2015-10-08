class CreateOldInvoiceDetails < ActiveRecord::Migration
  def change
    create_table :old_invoice_details do |t|
      t.text :invoice_detail_id 
      t.text :invoice_id 
      t.text :invoice_detail_name 
      t.text :invoice_detail_price 
      t.text :invoice_detail_price_discount 
      t.text :invoice_detail_type 
      t.text :invoice_discount 
      t.text :invoice_exchange

      t.timestamps null: false
    end
  end
end
