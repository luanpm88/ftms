class OldCourse < ActiveRecord::Base

	def self.import_old_course(database)
		OldCourse.destroy_all
		database[:Course].each do |row|
			course = OldCourse.new
			course.course_id = row[:CourseID]
			course.course_name = row[:CourseName]
			course.order = row[:Order]
			course.save
		end
	end
	
	

end
