class ContactsCourse < ActiveRecord::Base
  belongs_to :contact
  belongs_to :course
  
  belongs_to :course_register
  
  
end
