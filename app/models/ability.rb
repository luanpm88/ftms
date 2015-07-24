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
      can :update, Contact do |contact|
        contact.user_id == user.id
      end
      
      can :ajax_show, Contact
      can :ajax_new, Contact
      can :ajax_create, Contact
      can :ajax_list_agent, Contact
      can :ajax_list_supplier_agent, Contact
      can :ajax_destroy, Contact do |c|
        c.user_id == user.id && c.contact_types.include?(ContactType.agent) && Order.where("agent_id = ? OR supplier_agent_id = ?", c.id, c.id).count == 0
      end
      can :ajax_edit, Contact do |c|
        c.user_id == user.id && c.contact_types.include?(ContactType.agent) && Order.where("agent_id = ? OR supplier_agent_id = ?", c.id, c.id).count == 0
      end
      can :ajax_update, Contact do |c|
        c.user_id == user.id && c.contact_types.include?(ContactType.agent) && Order.where("agent_id = ? OR supplier_agent_id = ?", c.id, c.id).count == 0
      end
      
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
    end
    
    if user.has_role? "manager"
      can :course_features, User
      can :book_features, User
      
      can :datatable, CourseType
      can :read, CourseType
      can :create, CourseType
      can :update, CourseType
      #can :destroy, CourseType
      
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
      
      can :course_register, Contact do |contact|
        contact.contact_types.include?(ContactType.student) || contact.contact_types.include?(ContactType.inquiry)
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
    end
    
  end
end
