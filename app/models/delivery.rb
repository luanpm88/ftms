class Delivery < ActiveRecord::Base
  belongs_to :course_register
  belongs_to :user
  
  after_save :update_statuses
  
  def update_statuses
    course_register.update_statuses
  end
end
