Nahual::Application.routes.draw do
  devise_for :users

  #devise_scope :user do
  #  root 'devise/sessions#new'
  #end

  root :to => 'admins#index'

  resources :clients

  resources :admins

  resources :disciplines do
    member do
      post 'disable_all'
      post 'enable_all'
    end
  end

  resources :users, :only => [:index, :destroy, :edit, :update] do
    resources :payments, :only => [:new, :create]
    collection do
      get 'credits', to: 'users#credits'
      post 'reset', to: 'users#reset'
      post 'set_reset', to: 'users#set_reset'
      get 'reset_search', to: 'users#reset_search'
      get 'stop_impersonating'
    end
    member do
      get 'impersonate'
      post 'certificate'
    end
  end

  resources :shifts do
    member do
      get 'inscription'
      get 'cancel_inscription'
      get 'indiscriminate_inscription'
    end
  end

  resources :payments, :only => [:index, :destroy]

  resources :rookies do
    collection do
      get 'new_in_shift/:shift_id', to: 'rookies#new_in_shift', as: 'new_in_shift'
    end
    member do
      post 'attended'
    end
  end

  resources :stats, :only => [:index] do
    collection do
      get 'month_inscriptions_chart', to: 'stats#month_inscriptions_chart', as: 'month_inscriptions_chart'
    end
  end

  resources :inscriptions
  post 'incriptions/:id/attended', to: 'inscriptions#attended'

end
