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
  
  
  
  
end
