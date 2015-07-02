Hkerp::Application.routes.draw do
  resources :contact_tags_contacts
  resources :contact_tags
  resources :books do
    collection do
      get :datatable
      get :cover
    end
  end
  
  resources :courses do
    collection do
      get :datatable
    end
  end
  
  resources :subjects do
    collection do
      get :datatable
    end
  end
  
  resources :course_types do
    collection do
      get :datatable
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
      end
    end
  end
  
  resources :users do
    collection do
      get :avatar
      get :activity_log
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
