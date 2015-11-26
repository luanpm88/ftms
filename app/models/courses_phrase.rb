class CoursesPhrase < ActiveRecord::Base
  belongs_to :phrase
  belongs_to :course
  validates :phrase_id, :presence => true
  
  def all_transfer_details
    TransferDetail.where("courses_phrase_ids LIKE ?","%[#{self.id}]%")
  end
  
  def display_name
    (self.start_at.strftime("%d-%b-%Y")+" <span class=\"badge badge-success \">#{self.hour.to_s}</span>").html_safe
    # "["+course.course_type.short_name+"-"+course.subject.name+" ("+self.start_at.strftime("%d-%b-%Y")+")"+", "+self.hour.to_s+" hours"+"]"
  end
  
  def registered?(contact)
    ccs = ContactsCourse.where(contact_id: contact.id).where(course_id: self.course.id).where("courses_phrase_ids LIKE ?","%[#{self.id}]%")
    
    if ccs.empty?
      return false
    else
      num = 0
      ccs.each do |cc|        
        num += 1
        if transferred?(cc)
          num -= 1
        end
      end
      return num > 0
    end    
  end
  
  def transferred?(contacts_course)    
    !all_transfer_details.where(contacts_course_id: contacts_course.id).empty?
  end
  
  def name
    course.name+"-"+phrase.name
  end
  
  def courses_phrase_money(contact, course)
    cc = contact.active_contacts_courses.where(course_id: course.id).where("courses_phrase_ids LIKE ?", "%[#{self.id}]%").first
    return 0 if cc.nil? || hour.nil?
    
    total = cc.price
    hours = 0
    ContactsCourse.find(cc.id).courses_phrases.each do |cp|
      hours += cp.hour
    end
    
    return (total/hours)*hour
  end
  
  def used_count
    ContactsCourse.joins("LEFT JOIN course_registers ON course_registers.id = contacts_courses.course_register_id")
                  .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                  .where("contacts_courses.courses_phrase_ids LIKE ?", "%[#{self.id}]%").count
  end
  
  def used?
    used_count > 0
  end
  
  def release
    # Remove from contacts courses
    ContactsCourse.where("courses_phrase_ids LIKE ?", "%[#{self.id.to_s}]%").each do |c|
      c.update_attribute(:courses_phrase_ids, c.courses_phrase_ids.gsub("[#{self.id.to_s}]",""))
    end
    
    # Remove from transfer-from
    Transfer.where("courses_phrase_ids LIKE ?", "%[#{self.id.to_s}]%") do |c|
      c.update_attribute(:courses_phrase_ids, c.courses_phrase_ids.gsub("[#{self.id.to_s}]",""))
    end
    
    # Remove from transfer-to
    Transfer.where("to_courses_phrase_ids LIKE ?", "%[#{self.id.to_s}]%") do |c|
      c.update_attribute(:to_courses_phrase_ids, c.to_courses_phrase_ids.gsub("[#{self.id.to_s}]",""))
    end
  end
  
  def update_new
    # Remove from contacts courses
    ccs = ContactsCourse.where("course_id = ?", course.id) #.map(&:course_register_id)
    #crs = CourseRegister.main_course_registers.where(id: )
    ccs.each do |cc|
      puts cc.courses_phrases.count.to_s+" "+course.courses_phrases.count.to_s+" "+cc.course_register.contact.name
    end
  end
  
end
