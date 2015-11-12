class RelatedContact < ActiveRecord::Base
  def add_contact(contact)
    arr = contacts
    arr << contact if !arr.include?(contact)
    self.update_attribute(:contact_ids, "["+arr.map(&:id).join("][")+"]")
    contact.update_attribute(:cache_group_id, self.id)
    self.update_cache_search
  end
  
  def remove_contact(contact)
    arr = []
    contacts.each do |c|
      arr << c if c != contact
    end
    self.update_attribute(:contact_ids, "["+arr.map(&:id).join("][")+"]")
    contact.update_attribute(:cache_group_id, nil)
    self.update_cache_search
    
    # add to tmp
    add_removed_contact(contact)
    
    if self.contacts.count <= 1
      self.contacts.update_all(cache_group_id: nil)
      self.destroy
    end    
  end
  
  def contacts
    return [] if contact_ids.nil?
    c_ids = self.contact_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return Contact.where(id: c_ids)
  end
  
  def update_cache_search
    str = []
    contacts.each do |c|
      str << c.cache_search
    end
    self.update_attribute(:cache_search, str.join(" "))
  end
  
  
  # FOR TMP REMOVED
  def add_removed_contact(contact)
    arr = removed_contacts
    arr << contact if !arr.include?(contact)
    self.update_attribute(:removed_contact_ids, "["+arr.map(&:id).join("][")+"]")
  end
  
  def restore_contact(contact)
    arr = []
    removed_contacts.each do |c|
      arr << c if c != contact
    end
    self.update_attribute(:removed_contact_ids, "["+arr.map(&:id).join("][")+"]")
    self.add_contact(contact)
  end
  
  def removed_contacts
    return [] if removed_contact_ids.nil?
    c_ids = self.removed_contact_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return Contact.where(id: c_ids)
  end
  
  
end
