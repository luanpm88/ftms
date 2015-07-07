class CourseRegister < ActiveRecord::Base
  belongs_to :user
  
  has_many :contacts_courses
  
  def save_contact_courses(cid, cids)
    contact = Contact.find(cid)
    contact.update_attribute(:course_ids, cids+contact.courses.map(&:id))
    
    contact.contacts_courses.where(course_id: cids).each do |cc|
      if cc.course_register_id.nil?
        cc.update_attribute(:course_register_id, self.id)
      end      
    end
    
    contact.update_cache_course_type_ids
    contact.update_cache_intakes
    contact.update_cache_subjects
  end
  
end
