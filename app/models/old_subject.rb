class OldSubject < ActiveRecord::Base

	def self.import_old_subject(database)
		OldSubject.destroy_all
		database[:Subject].each do |row|
			subject = OldSubject.new
			subject.subject_id = row[:SubjectID]
			subject.course_id = row[:CourseID]
			subject.subject_name = row[:SubjectName]
			subject.subject_lecturer = row[:SubjectLecturer]
			subject.start_date = row[:StartDate]
			subject.end_date = row[:EndDate]
			subject.belong_to = row[:BelongTo]
			subject.subject_phrase = row[:SubjectPhrase]
			subject.save
		end
	end

end
