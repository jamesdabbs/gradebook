if host = ENV["HOST_URL"]
  Rails.application.routes.default_url_options[:host] = host
end

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  as :user do
    get 'signin' => 'static_pages#root', :as => :new_user_session
    delete 'signout' => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :assignments, except: :delete do
    member do
      post :assign
      post :check
    end
  end

  resources :courses, only: [:index, :show, :new, :create] do
    member do
      get  :shuffle # For picking a random student / teams
      post :sync
    end
  end

  resources :users, only: [:show]
  resource :user, only: [:edit] do
    # Obnoxiously, the default form for to update does the wrong thing
    #   so we need to manually reverse this
    patch :update, as: :update
  end

  post '/hooks/issues' => 'solutions#receive_hook', as: :receive_solutions_hook

  root to: 'static_pages#root'
end
