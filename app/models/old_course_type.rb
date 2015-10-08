class OldCourseType < ActiveRecord::Base

	def self.import_old_course_type(database)
		OldCourseType.destroy_all
		database[:CourseType].each do |row|
			course_type = OldCourseType.new
			course_type.course_type_id = row[:CourseTypeID]
			course_type.course_type_name = row[:CourseTypeName]
			course_type.course_type_short_name = row[:CourseTypeShortName]
			course_type.course_discount = row[:CourseDiscount]
			course_type.course_discount_value = row[:CourseDiscountValue]
			course_type.course_inquiry = row[:CourseInquiry]
			course_type.save
		end
	end

end
