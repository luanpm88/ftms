class CoursesPhrase < ActiveRecord::Base
  belongs_to :phrase
  belongs_to :course
  validates :phrase_id, :presence => true
  
  def display_name
    course.course_type.short_name+"-"+course.subject.name+" ("+self.start_at.strftime("%d-%b-%Y")+")"
  end
  
end
