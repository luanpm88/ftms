class ContactType < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  
  has_and_belongs_to_many :contacts
  
  def self.student
    self.find_by_name('Student')
  end
  
  def self.lecturer
    self.find_by_name('Lecturer')
  end
  
  def self.inquiry
    self.find_by_name('Inquiry')
  end
  
end
