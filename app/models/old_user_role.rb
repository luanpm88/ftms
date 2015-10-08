class OldUserRole < ActiveRecord::Base

	def self.import_old_user_role(database)
		OldUserRole.destroy_all
		database[:UserRole].each do |row|
			user_role = OldUserRole.new
			user_role.user_role_id = row[:UserRoleID]
			user_role.user_role = row[:UserRole]
			user_role.user_role_detail = row[:UserRoleDetail]
			user_role.save
		end
	end
	
end