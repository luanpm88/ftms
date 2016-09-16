Hkerp::Application.routes.draw do
  resources :sales_targets do
    collection do
      get :datatable
      get :delete
      get :undo_delete
    end
  end
  resources :report_periods do
    collection do
      get :datatable
      get :delete
      get :undo_delete
    end
  end
  resources :user_logs do
    collection do
      get :datatable
    end
  end
  resources :related_contacts
  resources :stock_types do
    collection do
      get :datatable
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      get :undo_delete
      
      ####################
      
      post :approve_all
      get :update_order
    end
  end
  resources :course_types_discount_programs
  resources :transfer_details
  resources :payment_record_details
  resources :transfers do
    collection do
      get :datatable
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      get :undo_delete
      
      ####################
      
      get :pay
      
      get :transfer_hour
      patch :do_transfer_hour
      
      post :approve_all
      
      get :pay_by_credit
    end
  end
  resources :activities do
    collection do
      get :datatable
      get :approve_delete
      get :undo_delete
      get :change
      
      post :approve_all
    end
  end
  resources :payment_records do
    collection do
      get :print
      get :datatable
      get :trash
      get :payment_list
      get :datatable_payment_list
      
      get :company_pay
      post :do_company_pay
      post :print_payment_list
      get :print_payment_list
      
      post :pay_transfer
      get :part_info
      
      get :company_paid_list
      
      post :export_list
    end
  end
  resources :stock_updates do
    collection do
      get :datatable
      get :import_export_form_list
      post :import_export
    end
  end
  resources :delivery_details
  resources :deliveries do
    collection do
      get :print
      get :delivery_list
      get :trash
      
      
    end
  end
  resources :books_contacts do
    collection do
      get :datatable
      get :check_upfront
      get :remove
      
      get :upfront_book_select_box
      
      get :delete
      post :delete_all
    end
  end
  resources :book_prices
  resources :bank_accounts do
    collection do
      get :datatable
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      ####################
      
      get :undo_delete
      
      post :approve_all
    end
  end
  resources :course_prices
  resources :contacts_lecturer_course_types
  resources :settings
  resources :discount_programs do
    collection do
      get :datatable
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      get :undo_delete
      
      ####################
      
      post :approve_all
      post :delete_all
    end
  end
  resources :courses_phrases do
    collection do
      get :courses_phrases_select
    end
  end
  resources :phrases_subjects
  resources :phrases do
    collection do
      get :datatable
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      ####################
      
      get :undo_delete
      post :approve_all
      post :delete_all
    end
  end
  resources :contacts_course_types
  post "headshot/capture" => 'headshot#capture', :as => :headshot_capture
  resources :contacts_seminars
  resources :seminars do
    collection do
      get :datatable
      get :student_seminars
      get :add_contacts
      get :remove_contacts
      
      get :import_list
      patch :import_list
      
      get :check_contact
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      get :undo_delete
      
      ####################
      
      patch :do_import_list
      post :approve_all
    end
  end
  resources :contacts_courses do
    collection do
      get :report_toggle
    end
  end
  resources :course_registers do
    collection do
      get :datatable
      get :student_course_registers
      post :export_student_course
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      ####################
      
      get :add_stocks
      post :do_add_stocks
      get :delivery_print
      
      get :undo_delete
      post :approve_all
      get :part_info
    end
  end
  resources :course_types_subjects
  resources :contact_tags_contacts
  resources :contact_tags do
    collection do
      get :datatable
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      ####################
      
      post :approve_all
    end
  end
  resources :books do
    collection do
      get :datatable
      get :cover
      get :stock_select
      get :volumn_checkboxs
      get :stock_price_form
      get :student_books
      get :statistics
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      ####################
      
      get :stock_form_list
      get :delivery
      get :import_export
      post :delivery_note
      post :deliver_all
      post :delivery_counting
      get :stock_statistics
      get :undo_delete
      post :approve_all
      post :delete_all
    end
  end
  
  resources :courses do
    collection do
      get :datatable
      get :student_courses
      get :courses_phrases_checkboxs
      get :course_price_select
      
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      get :course_phrases_form
      get :transfer_course
      get :course_phrases_list
      get :transfer_to_box
      
      get :report_toggle
      get :undo_delete
      post :approve_all
      post :delete_all
      
      get :intake_options
      
      post :print_list
    end
  end
  
  resources :subjects do
    collection do
      get :datatable
      get :ajax_select_box
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      ####################
      
      get :undo_delete
      post :approve_all
      post :delete_all
    end
  end
  
  resources :course_types do
    collection do
      get :datatable
      
      ### revision ###
      get :delete
      get :approve_new
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      ####################
      
      get :undo_delete
      post :approve_all
      post :delete_all
    end
  end
  
  resources :city_types
  resources :cities do
    collection do
      get :select_tag
    end
  end
  resources :states
  resources :countries
  resources :autotask_details
  resources :autotasks
  
  default_url_options :host => "27.0.15.181:3000"

  resources :notifications do
    collection do
      get :read_notification
      get :update_notification
    end
  end

  get 'home/index'
  get 'home/close_tab'
  get 'home/main_menu'
  
  resources :old_tags do
    collection do
      get :delete
    end
  end
  
  resources :old_link_students

  resources :roles

  devise_for :users, :controllers => { :registrations => "registrations" }
  
  scope "/admin" do
    resources :users do
      collection do
        get :backup
        post :backup
        
        get :restore
        post :restore
        
        get :download_backup
        get :delete_backup
        
        get :datatable
        
        get :import_from_old_system
        post :import_from_old_system
        
        get :system_setting
        post :system_setting
        
        get :delete
      end
    end
  end
  
  resources :users do
    collection do
      get :avatar
      get :activity_log
      
      get :statistic
      get :statistics_enhanced
      get :download_statistics
      
      get :online_report
      post :online_report
      
      get :user_guide
    end
  end
  

  resources :contact_types

  resources :contacts do
    collection do
      post :import
      get :ajax_new
      get :ajax_edit
      post :ajax_create
      patch :ajax_update
      get :ajax_show
      get :ajax_destroy
      get :ajax_show
      get :ajax_list_agent
      get :ajax_list_supplier_agent
      
      get :datatable
      
      get :logo
      get :update_tag
      
      get :ajax_quick_info
      get :course_students
      get :seminar_students
      post :export_list
      get :related_info_box
      
      get :delete
      
      get :approve_new
      get :approve_education_consultant
      get :approve_update
      get :approve_delete
      
      get :approved
      get :field_history
      
      post :export_mobiles
      post :export_emails

      get :merge_contacts
      get :merge_contacts_datatable
      
      get :undo_delete
      
      get :remove_related_contact
      get :undo_remove_related_contact
      
      get :merge_all_infos
      
      post :approve_all
      post :delete_all
      
      get :part_info
      post :do_merge
      
      get :print
      
      post :not_related_contacts
      
      get :transfer_money_history
      get :transfer_hour_history
      
      post :merge_companies
      
      post :add_tags
      post :remove_tags
      post :remove_company
      
      get :add_custom_payment
      post :add_custom_payment
    end
  end


  get 'admin' => 'admin#index'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'devise/sessions#new'
  
  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end
  
    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     #   end

end
