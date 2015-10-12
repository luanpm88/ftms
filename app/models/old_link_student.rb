class OldLinkStudent < ActiveRecord::Base
    belongs_to :old_student, foreign_key: 'student_id', primary_key: 'student_id'

    has_one :old_company, foreign_key: 'company_id', primary_key: 'company_id'
    
    def self.import_old_link_student(database)
        #database = Mdb.open(file)
        #result = {id: [], subject_id: [], student_id:[], subject_array: [], company_id: [], paid: [], count_for: [], defferal: []}
		OldLinkStudent.destroy_all
		database[:LinkStudent].each do |row|
			link_student = OldLinkStudent.new
			link_student.id = row[:ID]
			link_student.subject_id = row[:SubjectID]
			link_student.student_id = row[:StudentID]
			link_student.subject_array = row[:SubjectArray]
			link_student.company_id = row[:CompanyID]
			link_student.paid = row[:Paid]
			link_student.count_for = row[:Countfor]
			link_student.defferal = row[:Defferal]
			link_student.save
		end
	end
    
    def self.full_text_search(params)    
		tags = self.order("subject_id").where("LOWER(old_link_students.subject_id) LIKE ?", "%#{params[:q].strip.downcase}%").limit(50)
		tags = (tags.map {|c| c.subject_id}).uniq
		tags = tags.map {|model| {:id => model, :text => model} }
	end

end