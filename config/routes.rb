Rails.application.routes.draw do
  get 'vendors/index'

  devise_for :vendors
  devise_scope :vendor do
    get "mikescoffeeshop/admin" => "vendors#index"
    authenticated :vendor do
      root to: redirect("mikescoffeeshop/admin")
    end
    # unauthenticated :vendor do
    #   # root :to => "devise/sessions#new", as: :unauthenticated_vendor_root
    #   root :to => "home#home", as: :unauthenticated_vendor_root
    # end
  end
  devise_for :dispatchers, :controllers => {:confirmations => 'dispatchers/confirmations', :sessions => 'dispatchers/sessions'}
  devise_scope :dispatcher do
    patch "/confirm" => "dispatchers/confirmations#confirm"
    authenticated :dispatcher do
      root to: "home#dashboard", as: :authenticated_root
    end
    # unauthenticated :dispatcher do
    #   root :to => "home#home", as: :unauthenticated_root
    # end
  end
  unauthenticated :dispatcher do
    root :to => "home#home", as: :unauthenticated_root
  end
  get 'location_detail_popup' => 'location_details#location_detail_popup'
  get 'tracking_result/:url_token' => 'location_details#tracking_result',as: :tracking_result
  get 'refresh_tracking_result/:url_token' => 'location_details#refresh_tracking_result',as: :refresh_tracking_result
  get 'set_next_refresh_second/:url_token' => 'location_details#set_next_refresh_second',as: :set_next_refresh_second
  get 'get_new_time/:url_token' => 'location_details#get_new_time',as: :get_new_time
  post 'location_detail' => 'location_details#location_detail', as: :'location_detail_resolve'
  get "mikescoffeeshop/admin/map" => "vendors#vendor_map", as: :vendor_map
  get "get_new_location" => "vendors#get_new_location", as: :get_new_location
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'


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
  #     resources :products
  #   end
end
