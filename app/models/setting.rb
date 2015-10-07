class Setting < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  
  def self.get(name)
    self.where(name: name).first.value
  end
  
  def self.set(name, val)
    setting = self.where(name: name).first
    setting.update_attribute(:value, val)
  end
  
end
