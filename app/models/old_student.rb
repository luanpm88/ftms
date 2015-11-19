class OldStudent < ActiveRecord::Base

	belongs_to :old_consultant, foreign_key: 'consultant_id', primary_key: 'consultant_id'
	has_one :contact, foreign_key: 'tmp_StudentID', primary_key: 'student_id'

	def self.import_old_student(database)
		
		OldStudent.destroy_all
		database[:Student].each do |row|
			student = OldStudent.new
			student.student_id = row[:StudentID]
			student.consultant_id = row[:CounsultantID]
			student.student_name = row[:StudentName]
			student.student_title = row[:StudentTitle]
			student.student_birth = row[:StudentBirth].to_date if !row[:StudentBirth].nil?
			student.student_acca_no = row[:StudentACCANo]
			student.student_company = row[:StudentCompany]
			student.student_vat_code = row[:StudentVATCode]
			student.student_office = row[:StudentOffice]
			student.student_location = row[:StudentLocation]
			student.student_home_add = row[:StudentHomeAdd]
			student.student_preffer_mailing = row[:StudentPrefferMailling]
			student.student_email_1 = row[:StudentEmail1]
			student.student_email_2 = row[:StudentEmail2]
			student.student_off_phone = row[:StudentOffPhone]
			student.student_hand_phone = row[:StudentHandPhone]
			student.student_fax = row[:StudentFax]
			student.student_type = row[:StudentType]
			student.student_tags = row[:StudentTags]
			student.student_hand_phone = row[:StudentHandPhone]
			student.save
		end	
	end

end