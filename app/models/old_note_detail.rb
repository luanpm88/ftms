class OldNoteDetail < ActiveRecord::Base

	def self.import_old_note_detail(database)
		OldNoteDetail.destroy_all
		database[:NoteDetail].each do |row|
			note_detail = OldNoteDetail.new
			note_detail.note_id = row[:NoteID]
			note_detail.student_id = row[:StudentID]
			note_detail.cus_id = row[:CusID]
			note_detail.note_date = row[:NoteDate].to_date
			note_detail.note_detail = row[:NoteDetail]
			note_detail.priority = row[:Priority]
			note_detail.staff = row[:Staff]
			note_detail.save
		end
	end

end
