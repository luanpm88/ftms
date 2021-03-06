Hkerp::Application.routes.draw do
  resources :product_images do
    collection do
      get :image
    end
  end
  resources :commission_programs do
    collection do
      get :start
      get :stop
      
      get :statistics
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

  resources :payment_records do
    collection do
      get :download_pdf
      get :pay_tip
      post :do_pay_tip
      
      get :pay_custom
      post :do_pay_custom
      
      get :trash
      get :custom_payments
      get :datatable
      
      get :edit_pay_custom
      get :statistics
      
      get :pay_commission
      post :do_pay_commission
    end
  end


  resources :deliveries do
    collection do
      get :deliver
      get :download_pdf
      get :trash
    end
  end


  resources :sales_deliveries do
    collection do
      get :deliver
      get :download_pdf
    end
  end

  resources :notifications do
    collection do
      get :read_notification
      get :update_notification
    end
  end


  resources :checkinout_requests do
    collection do
      get :approve
    end
  end

  get 'home/index'
  get 'home/close_tab'

  resources :checkinouts do
    collection do
      post :import
      get :import
      get :detail
    end
  end


  resources :roles


  resources :order_details do
    collection do
      get :ajax_new
      post :ajax_create
      delete :ajax_destroy
      get :ajax_edit
      patch :ajax_update
    end
  end


  resources :orders do
    collection do
      get :download_pdf
      get :print_order
      get :print_order_fix1
      get :purchase_orders
      get :confirm_order
      get :datatable
      get :pdf_preview
      get :change
      patch :do_change
      get :confirm_items
      
      get :pricing_orders
      get :update_price
      patch :do_update_price
      get :confirm_price
      
      get :update_info
      patch :do_update_info
      
      get :finish_order
      
      get :order_log
      
      get :update_tip
      patch :do_update_tip
      
      get :order_actions
    end
  end

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
    end
  end

  resources :parent_categories


  get 'admin' => 'admin#index'
  
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  resources :products do
    collection do
      get :ajax_show
      get :ajax_new
      post :ajax_create
      get :datatable
      get :sales_delivery
      get :update_price
      patch :do_update_price
      
      patch :trash
      patch :un_trash
      
      get :statistics
      get :ajax_product_prices
      
      get :product_log
    end
  end
  
  resources :accounting do
    collection do
      get :orders
      get :pay
      
      get :statistic_sales
      get :statistic_purchase
    end
  end

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
