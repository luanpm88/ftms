class CourseRegister < ActiveRecord::Base
  belongs_to :user
  
  has_many :contacts_courses
  
  def save_contacts_courses(cid, cids)
    contact = Contact.find(cid)
    
    cids.each do |row|
      if row[1]["course_id"].present?
        contact.contacts_courses.create(course_id: row[1]["course_id"],
                                        courses_phrase_ids: row[1]["courses_phrase_ids"].to_s,
                                        course_register_id: self.id
                                      )
      end
    end
    
    #change contact type when add course
    if !contact.contacts_courses.empty?
      contact.contact_types.delete(ContactType.inquiry)
      contact.contact_types << ContactType.student if !contact.contact_types.include?(ContactType.student)
      contact.save
    end    
    
    contact.update_cache_course_type_ids
    contact.update_cache_intakes
    contact.update_cache_subjects
  end
  
end
