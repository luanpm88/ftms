class ContactsLecturerCourseType < ActiveRecord::Base
  belongs_to :contact
  belongs_to :course_type
end
