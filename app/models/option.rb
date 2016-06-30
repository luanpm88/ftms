class Option < ActiveRecord::Base
    validates :name, :presence => true, :uniqueness => true
    
    def self.get(name)
        option = self.where(name: name).first
        option.nil? ? nil : option.value
    end
    
    def self.set(name, value)
        option = self.where(name: name).first
        if option.nil?
            self.create(name: name, value: value)
        else
            option.update_attribute(:value, value)
        end
    end
end
