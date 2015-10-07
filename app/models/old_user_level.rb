class OldUserLevel < ActiveRecord::Base

	def self.import_old_user_level(database)
		OldUserLevel.destroy_all
		database[:UserLevel].each do |row|
			user_level = OldUserLevel.new
			user_level.user_permission_id = row[:UserPermissionID]
			user_level.user_name = row[:UserName]
			user_level.user_role = row[:UserRole]
			user_level.consultant_id = row[:ConsultantID]
			user_level.in_charge = row[:InCharge]
			user_level.save
		end
	end

end
