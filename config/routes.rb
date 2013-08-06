BmCm::Application.routes.draw do
  
  match '/reports', :to => 'reports#create', :via => :post, :as => 'report_path'

  resources :sessions, :only => [:new, :create, :destroy]
  resources :users
  resources :flows
  resources :nodes, :only => [:new, :create, :destroy, :index, :show]
  resources :installers, :only => [:new, :create]
  resources :nodes do
    resources :reports, :only => [:show, :index]
  end

  root :to => 'pages#home'
  match '/get_started', :to => 'pages#get_started'
  match '/flows_home', :to => 'flows#home', :as => "flows_home"
  match '/nodes_home', :to => 'nodes#home', :as => "nodes_home"
  match '/signup', :to => 'users#new'
  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy', :via => :delete #DELETE HTTP
  match '/installers/download', :to => 'installers#download', :via => :get, :as => "download_installer"
  match '/installers/destroy', :to =>  'installers#destroy', :as => "destroy_installer", :via => :delete
  match '/flows/:id/download', :to => "flows#download", :via => :get, :as => "download_flow"
  match '/nodes/:node_id/reports/:id/download', :to => "reports#download", :via => :get, :as => "download_report"
  match '/nodes_and_reports', :to => 'nodes#index_nodes_and_reports', :via => :get, :as => 'nodes_and_reports'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
