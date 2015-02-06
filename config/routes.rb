Rails.application.routes.default_url_options[:host] = 'greatbook.herokuapp.com'

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

  resources :teams, only: [:index, :show, :new, :create] do
    member do
      get  :shuffle # For picking a random student / teams
      post :activate
      post :sync
    end
  end

  resources :users, only: [:show]

  get  '/user/access_token' => 'github_access_token#edit'
  post '/user/access_token' => 'github_access_token#update'

  post '/hooks/issues' => 'solutions#receive_hook', as: :receive_solutions_hook

  root to: 'static_pages#root'
end
