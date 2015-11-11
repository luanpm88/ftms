class RelatedContact < ActiveRecord::Base
  def add_contact(contact)
    arr = contacts
    arr << contact if !arr.include?(contact)
    self.update_attribute(:contact_ids, "["+arr.map(&:id).join("][")+"]")
    contact.update_attribute(:cache_group_id, self.id)
  end
  
  def remove_contact(contact)
    arr = []
    contacts.each do |c|
      arr << c if c != contact
    end
    self.update_attribute(:contact_ids, "["+arr.map(&:id).join("][")+"]")
    contact.update_attribute(:cache_group_id, nil)
  end
  
  def contacts
    return [] if contact_ids.nil?
    c_ids = self.contact_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return Contact.where(id: c_ids)
  end
  
end
