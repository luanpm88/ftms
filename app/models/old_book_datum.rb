class OldBookDatum < ActiveRecord::Base

	def self.import_old_book_data(database)
		OldBookDatum.destroy_all
		database[:BookData].each do |row|
			book_data = OldBookDatum.new
			book_data.book_data_id = row[:BookDataID]
			book_data.book_data_name = row[:BookDataName]
			book_data.book_data_array = row[:BookDataArray]
			book_data.save
		end
	end

end