class CoursesPhrase < ActiveRecord::Base
  belongs_to :phrase
  belongs_to :course
  validates :phrase_id, :presence => true
end
