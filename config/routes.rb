Nahual::Application.routes.draw do
  devise_for :users

  #devise_scope :user do
  #  root 'devise/sessions#new'
  #end

  root :to => 'admins#index'

  resources :clients

  resources :admins

  resources :users do
    resources :payments, :only => [:new, :create]
  end

  resources :shifts do
    member do
      get 'inscription'
      get 'cancel_inscription'
    end
  end

  resources :payments, :only => [:destroy] do
    collection do
      get 'user_payments/:user_id', to: 'payments#user_payments', as: 'user_payments'
      get 'search', to: 'payments#search', as: 'search_payments'
    end

  end

  resources :rookies do
    collection do
      get 'new_in_shift/:shift_id', to: 'rookies#new_in_shift', as: 'new_in_shift'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'devise/registrations#new'

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
