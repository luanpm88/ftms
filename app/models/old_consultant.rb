class OldConsultant < ActiveRecord::Base

	def self.import_old_consultant(database)
		OldConsultant.destroy_all
		database[:Counsultant].each do |row|
			consultant = OldConsultant.new
			consultant.consultant_id = row[:ConsultantID]
			consultant.consultant_name = row[:ConsultantName]
			consultant.save
		end
	end

end
