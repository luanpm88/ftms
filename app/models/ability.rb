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
    end
    
    if user.has_role? "manager"
      can :course_features, User
      
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
    end
    
  end
end
