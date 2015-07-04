class ContactType < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  
  has_and_belongs_to_many :contacts
  
  def self.student
    self.find_by_name('Student')
  end
  
  def self.agent
    self.find_by_name('Agent').id.to_s
  end
  
end
