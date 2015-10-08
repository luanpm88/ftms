class OldTag < ActiveRecord::Base

	def self.import_old_tag(database)
		OldTag.destroy_all
		database[:Tags].each do |row|
			tag = OldTag.new
			tag.tag_id = row[:TagID]
			tag.student_id = row[:StudentID]
			tag.tag_name = row[:TagName]
			tag.save
		end
	end

end
