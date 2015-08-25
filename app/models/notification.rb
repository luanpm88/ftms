class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, :class_name => "User"
  
  def normal
  end
  
  def self.send_email(n)
    UserMailer.send_notification(n).deliver
  end
  
  def self.send_notification(current_user, type, item)    
    
    case type
    when 'xxx'
      #users = User.joins(:roles)
      #            .where(roles: {name: 'purchaser'})
      #
      #if !item.purchaser.nil?
      #  users = users.where(id: item.purchaser.id)
      #end      
      #
      #users.each do |user|
      #  n = Notification.new
      #  n.type_name = type
      #  n.user = user
      #  n.sender = current_user
      #  n.item_id = item.id
      #  
      #  n.save
      #  
      #  #send_email(n)
      #end
    
    else
    end
    
    
  end
  
  def display_title
    case type_name
    when 'xxx'
      "xxx"
    else
    end
  end
  
  def display_description
    case type_name
    when 'xxx'
      
    else
    end
  end
  
  def display_url
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    case type_name
    when 'xxx'
      
    else
    end
  end
  
  def self.contact_pending_count(user)
    if !user.has_role?("education_consultant") && !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end       
    
    if user.has_role?("education_consultant") && !user.has_role?("admin") && !user.has_role?("manager")
      records = Contact.main_contacts.where("contacts.status LIKE ? OR contacts.status LIKE ? OR contacts.status LIKE ?","%[new_pending]%","%[update_pending]%","%[delete_pending]%")
      records = records.where(account_manager: user.id)
    end
    
    if user.has_role?("admin") || user.has_role?("manager")
      records = Contact.main_contacts.where("contacts.status LIKE ?","%_pending]%")
    end
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.course_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = Course.main_courses.where("courses.status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.course_admin_count(user)
    self.course_pending_count(user)
  end
  
  
end
