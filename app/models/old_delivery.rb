class OldDelivery < ActiveRecord::Base
	belongs_to :contact, foreign_key: 'student_id', primary_key: 'tmp_StudentID'

	def self.import_old_delivery(database)
		OldDelivery.destroy_all
		database[:Delivery].each do |row|
			delivery = OldDelivery.new
			delivery.delivery_id = row[:DeliveryID]
			delivery.student_id = row[:StudentID]
			delivery.subject_id = row[:SubjectID]
			delivery.book_type = row[:BookType]
			delivery.book_vol = row[:BookVol]
			delivery.delivery_yes = row[:DeliveryYes]
			delivery.save
		end

	end
end
