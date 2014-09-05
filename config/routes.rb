Nahual::Application.routes.draw do
  devise_for :users

  #devise_scope :user do
  #  root 'devise/sessions#new'
  #end

  root :to => 'admins#index'

  resources :clients

  resources :admins

  resources :users, :only => [:destroy, :edit, :update] do
    resources :payments, :only => [:new, :create]
    collection do
      get 'credits', to: 'users#credits'
      post 'reset', to: 'users#reset'
      get 'reset_search', to: 'users#reset_search'
    end
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
      post 'payments/download', to: 'payments#download'
    end

  end

  resources :rookies do
    collection do
      get 'new_in_shift/:shift_id', to: 'rookies#new_in_shift', as: 'new_in_shift'
    end
  end

end
