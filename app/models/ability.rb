class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    # Handle the case where we don't have a current_user i.e. the user is a guest
    user ||= User.new

    # Define a few sample abilities
    # cannot :destroy, Contact
    # cannot :manage , Comment
    # can    :read   , Tag , released: true
    
    #can :manage, Order, :salesperson_id => user.id
    #can :manage, SupplierOrder, :salesperson_id => user.id
    
    if user.has_role? "admin"
      can :manage, :all
    end
    
    if user.has_role? "user"      
      can :read_notification, Notification
      
      can :read, User
      
      can :read, Contact
      can :datatable, Contact
      can :create, Contact
      can :update_tag, Contact
      can :course_students, Contact
      can :seminar_students, Contact
      can :export_list, Contact
      can :related_info_box, Contact
      can :add_course, Contact do |c|
        c.statuses.include?("active")
      end
      
      
      can :update, Contact do |contact|
        contact.user_id == user.id
      end
      can :delete, Contact do |c|
        !c.statuses.include?("delete_pending") && !c.statuses.include?("deleted")
      end
      
      can :ajax_show, Contact
      can :ajax_new, Contact
      can :ajax_create, Contact
      can :course_students, Contact
      can :seminar_students, Contact
      can :export_list, Contact
      can :related_info_box, Contact
      
      
      can :read, City
      can :read, State
      can :read, Country
      can :select_tag, City
      
      can :logo, Contact
      
      can :show, User
      can :avatar, User
      
      can :activity_log, User do |u|
        u == user
      end
      
      can :ajax_quick_info, Contact
      can :ajax_select_box, Subject
      
      can :datatable, CourseType
      can :read, CourseType
      
      can :datatable, Activity
      can :read, Activity
    end
    
    if user.has_role? "education_consultant"
      can :approve_new, Contact do |c|
        c.statuses.include?("new_pending") && c.account_manager  == user
      end
      can :approve_update, Contact do |c|
        c.statuses.include?("update_pending") && c.account_manager  == user
      end
      can :approve_delete, Contact do |c|
        c.statuses.include?("delete_pending") && c.account_manager  == user
      end
    end
    
    if user.has_role? "manager"
      can :course_features, User
      can :book_features, User
      
      can :datatable, CourseType
      can :read, CourseType
      can :create, CourseType
      can :update, CourseType
      
      can :datatable, Subject
      can :read, Subject
      can :create, Subject
      can :update, Subject
      
      can :datatable, Course
      can :read, Course
      can :create, Course
      can :update, Course
      can :student_courses, Course
      can :courses_phrases_checkboxs, Course
      can :course_price_select, Course
      
      can :update, Contact
      can :update_tag, Contact
      can :course_students, Contact
      can :seminar_students, Contact
      can :export_list, Contact
      can :related_info_box, Contact
      can :add_course, Contact do |c|
        c.statuses.include?("active")
      end
      can :approved, Contact

      can :approve_new, Contact do |c|
        c.statuses.include?("new_pending")
      end
      can :approve_update, Contact do |c|
        c.statuses.include?("update_pending")
      end
      can :approve_education_consultant, Contact do |c|
        c.statuses.include?("education_consultant_pending") && c.account_manager.present?
      end
      can :approve_delete, Contact do |c|
        c.statuses.include?("delete_pending")
      end
      can :field_history, Contact
      
      can :datatable, Book
      can :student_books, Book
      can :read, Book
      can :create, Book
      can :update, Book
      can :stock_select, Book
      can :volumn_checkboxs, Book
      can :stock_price_form, Book
      
      can :datatable, ContactTag
      can :read, ContactTag
      can :create, ContactTag
      can :update, ContactTag
      
      can :datatable, CourseRegister
      can :student_course_registers, CourseRegister
      can :read, CourseRegister
      can :create, CourseRegister
      can :update, CourseRegister
      can :deliver_stock, CourseRegister do |cr|
        cr.books.count > 0 && !cr.delivered?
      end
      can :delivery_print, CourseRegister
      can :pay_registration, CourseRegister do |cr|
        !cr.paid?
      end      
      can :course_register, Contact do |contact|
        contact.contact_types.include?(ContactType.student) || contact.contact_types.include?(ContactType.inquiry)
      end
      can :transfer_course, Contact do |contact|
        contact.contact_types.include?(ContactType.student)
      end
      
      can :datatable, Seminar
      can :read, Seminar
      can :create, Seminar
      can :update, Seminar
      can :add_contacts, Seminar
      can :remove_contacts, Seminar
      can :check_contact, Seminar
      
      can :seminar_features, Seminar
      
      can :datatable, Phrase
      can :read, Phrase
      can :create, Phrase
      can :update, Phrase
      
      can :datatable, DiscountProgram
      can :read, DiscountProgram
      can :create, DiscountProgram
      can :update, DiscountProgram
      
      can :import_list, Seminar
      
      can :datatable, BankAccount
      can :read, BankAccount
      can :create, BankAccount
      can :update, BankAccount
      
      can :courses_phrases_select, CoursesPhrase
      
      can :datatable, Delivery
      can :read, Delivery
      can :create, Delivery
      can :print, Delivery
      can :delivery_list, Delivery
      can :trash, Delivery
      
      can :read, DeliveryDetail
      can :create, DeliveryDetail
      
      can :read, StockUpdate
      can :create, StockUpdate
      
      can :datatable, PaymentRecord
      can :read, PaymentRecord
      can :create, PaymentRecord
      can :print, PaymentRecord
      can :trash, PaymentRecord
      
      can :datatable, Activity
      can :read, Activity
      can :create, Activity
      can :destroy, Activity do |a|
        a.user == user
      end
      
      can :datatable, Transfer
      can :read, Transfer
      can :create, Transfer
    end
  end
end
