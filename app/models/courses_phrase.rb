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
  
end
