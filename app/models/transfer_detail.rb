class TransferDetail < ActiveRecord::Base
  belongs_to :transfer
  belongs_to :contacts_course
  
  def courses_phrases
    cp_ids = self.courses_phrase_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CoursesPhrase.where(id: cp_ids).includes(:course).order("courses.intake, start_at")
  end
  
  def courses_phrase_ids=(ids)
    self[:courses_phrase_ids] = "["+(ids.map {|s| s.strip.to_i}).join("][")+"]"
  end
end
