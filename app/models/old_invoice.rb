class OldInvoice < ActiveRecord::Base
	belongs_to :old_student, foreign_key: 'student_id', primary_key: 'student_id'
	has_many :old_invoice_details, foreign_key: 'invoice_id', primary_key: 'invoice_id'

	def self.import_old_invoice(database)
		OldInvoice.destroy_all
		database[:Invoice].each do |row|
			invoice = OldInvoice.new
			invoice.invoice_id = row[:InvoiceID]
			invoice.student_id = row[:StudentID]
			invoice.paid = row[:Paid]
			invoice.count_for = row[:Countfor]
			invoice.save
		end
	end

end