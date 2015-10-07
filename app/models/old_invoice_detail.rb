class OldInvoiceDetail < ActiveRecord::Base

	belongs_to :old_invoice, foreign_key: 'invoice_id', primary_key: 'invoice_id'

	def self.import_old_invoice_detail(database)
		OldInvoiceDetail.destroy_all
		database[:InvoiceDetail].each do |row|
			invoice_detail = OldInvoiceDetail.new
			invoice_detail.invoice_detail_id = row[:InvoiceDetailID]
			invoice_detail.invoice_id = row[:InvoiceID]
			invoice_detail.invoice_detail_name = row[:InvoiceDetailName]
			invoice_detail.invoice_detail_price = row[:InvoiceDetailPrice]
			invoice_detail.invoice_detail_price_discount = row[:InvoiceDetailPriceDiscount]
			invoice_detail.invoice_detail_type = row[:InvoiceDetailType]
			invoice_detail.invoice_discount = row[:InvoiceDiscount]
			invoice_detail.invoice_exchange = row[:InvoiceExchange]
			invoice_detail.save
		end
	end

end
