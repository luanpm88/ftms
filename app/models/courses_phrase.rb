class CoursesPhrase < ActiveRecord::Base
  belongs_to :phrase
  belongs_to :course
  validates :phrase_id, :presence => true
  
  def display_name
    course.course_type.short_name+"-"+course.subject.name+" ("+self.start_at.strftime("%d-%b-%Y")+")"
  end
  
  def registered?(contact)
    cond = !ContactsCourse.where(contact_id: contact.id).where(course_id: self.course.id).where("courses_phrase_ids LIKE ?","%[#{self.id}]%").empty?
    return cond && !transferred?(contact)
  end
  
  def transferred?(contact)    
    !Transfer.where(contact_id: contact.id).where("courses_phrase_ids LIKE ?","%[#{self.id}]%").empty?
  end
  
  def name
    course.name+"-"+phrase.name
  end
  
end
