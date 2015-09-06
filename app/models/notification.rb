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
  
  
  
  #### CONTACT MENU- PENDING
  def self.contact_pending_count(user)
    if !user.has_role?("education_consultant") && !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end       
    
    if !user.has_role?("admin") && !user.has_role?("manager")
      if user.has_role?("education_consultant")
        records = Contact.main_contacts
                        .where("contacts.status LIKE ? OR contacts.status LIKE ? OR contacts.status LIKE ?","%[new_pending]%","%[update_pending]%","%[delete_pending]%")
        records = records.where(account_manager: user.id)
        records = records.select{|item| item.current.user.lower?("education_consultant")}
      end      
    else
      records = Contact.main_contacts.where("contacts.status LIKE ?","%_pending]%")
    end
    
    return records.count == 0 ? "" : records.count
  end
  
  
  
  def self.contact_tag_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = ContactTag.main_contact_tags.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  
  
  def self.contact_menu_count(user)
    total = self.contact_pending_count(user).to_i + self.contact_tag_pending_count(user).to_i
    
    return total > 0 ? total : ""
  end
  ###################################################
  
  
  
  
  #### CONTACT MENU- APPROVED   
  def self.contact_approved_count(user)
    records = Contact.main_contacts
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.contact_tag_approved_count(user)
    records = ContactTag.main_contact_tags
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.contact_menu_approved_count(user)
    total = self.contact_approved_count(user).to_i + self.contact_tag_approved_count(user).to_i
    
    return total > 0 ? total : ""
  end
  #########################################################
  
  
  
  #### COURSE ADMIN - PENDING
  
  def self.course_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = Course.main_courses.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.course_type_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = CourseType.main_course_types.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # subject
  def self.subject_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = Subject.main_subjects.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # phrase
  def self.phrase_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = Phrase.main_phrases.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # course register
  def self.course_register_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = CourseRegister.main_course_registers.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # course register
  def self.transfer_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = Transfer.main_transfers.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.course_admin_count(user)
    total = self.course_pending_count(user).to_i + self.course_type_pending_count(user).to_i + self.subject_pending_count(user).to_i + self.phrase_pending_count(user).to_i + self.course_register_pending_count(user).to_i + self.transfer_pending_count(user).to_i
    
    return total > 0 ? total : ""
  end
  
  #### COURSE ADMIN - APPROVED
  
  def self.course_approved_count(user)
    records = Course.main_courses
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # course type
  def self.course_type_approved_count(user)
    records = CourseType.main_course_types
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # subject
  def self.subject_approved_count(user)
    records = Subject.main_subjects
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # phrase
  def self.phrase_approved_count(user)
    records = Phrase.main_phrases
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # course regiser
  def self.course_register_approved_count(user)
    records = CourseRegister.main_course_registers
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  # transfer
  def self.transfer_approved_count(user)
    records = Transfer.main_transfers
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.course_admin_approved_count(user)
    total = self.course_approved_count(user).to_i + self.course_type_approved_count(user).to_i + self.subject_approved_count(user).to_i + self.phrase_approved_count(user).to_i + self.course_register_approved_count(user).to_i + self.transfer_approved_count(user).to_i
    
    return total > 0 ? total : ""
  end
  
  #### BOOK - PENDING - APPROVED
  
  def self.book_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager") # && !user.has_role?("education_consultant")
      return ""
    end
    
    records = Book.main_books.where("status LIKE ?","%pending]%")
    
    #if user.has_role?("education_consultant")
    #  records = records.select{|item| item.current.user.lower?("education_consultant")}
    #end
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.book_approved_count(user)
    records = Book.main_books
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  
  
  
  #### DISCOUNT PROGRAM - PENDING - APPROVED
  
  def self.discount_program_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager") # && !user.has_role?("education_consultant")
      return ""
    end
    
    records = DiscountProgram.main_discount_programs.where("status LIKE ?","%pending]%")
    
    #if user.has_role?("education_consultant")
    #  records = records.select{|item| item.current.user.lower?("education_consultant")}
    #end
    
    return records.count == 0 ? "" : records.count
  end
  
  def self.discount_program_approved_count(user)
    records = DiscountProgram.main_discount_programs
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  
  
  
  
  #### ACCOUNTING - PENDING
  def self.bank_account_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = BankAccount.main_bank_accounts.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  
  # total
  def self.accounting_count(user)
    total = self.bank_account_pending_count(user).to_i
    
    return total > 0 ? total : ""
  end
  #####################################
  
  
  
  
  #### ACCOUNTING - APPROVED
  def self.bank_account_approved_count(user)
    records = BankAccount.main_bank_accounts
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
    
  def self.accounting_approved_count(user)
    total = self.bank_account_approved_count(user).to_i
    
    return total > 0 ? total : ""
  end
  #######################################
  
  
  #### ACCOUNTING - PENDING
  def self.seminar_pending_count(user)
    if !user.has_role?("admin") && !user.has_role?("manager")
      return ""
    end
    
    records = Seminar.main_seminars.where("status LIKE ?","%pending]%")
    
    return records.count == 0 ? "" : records.count
  end
  
  
  # total
  def self.marketing_pending_count(user)
    total = self.seminar_pending_count(user).to_i
    
    return total > 0 ? total : ""
  end
  #####################################
  
  
  
  
  #### ACCOUNTING - APPROVED
  def self.seminar_approved_count(user)
    records = Seminar.main_seminars
                    .where("annoucing_user_ids LIKE ?", "%[#{user.id}]%")
    
    return records.count == 0 ? "" : records.count
  end
  
    
  def self.marketing_approved_count(user)
    total = self.seminar_approved_count(user).to_i
    
    return total > 0 ? total : ""
  end
  #######################################
  
  
  
end
