class OldBook < ActiveRecord::Base

	def self.import_old_book(database)
		OldBook.destroy_all
		database[:Book].each do |row|
			book = OldBook.new
			book.book_id = row[:BookID]
			book.subject_id = row[:SubjectID]
			book.book_type = row[:BookType]
			book.book_vol = row[:BookVol]
			book.amount = row[:Amount]
			book.delivered = row[:Delivered]
			book.need_delivery = row[:NeedDelivery]
			book.in_stock = row[:InStock]
			book.need_ordering = row[:NeedOrdering]
			book.remark = row[:Remark]
			book.remark1 = row[:Remark1]
			book.save
		end
	end

end