Nahual::Application.routes.draw do
  devise_for :users

  root :to => 'inscriptions#index'


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

  resources :past_shifts, :only => [:index, :show]

  resources :shifts do
    collection do
      get 'next_class'
    end
  end

  resources :payments, :only => [:index, :destroy] do
    collection do
      get 'total_payments', to: 'payments#total_payments'
    end
  end

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

  resources :messages
  resources :packs

  get 'check_pending_messages', to: 'application#check_pending_messages'
end
