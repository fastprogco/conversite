require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

   mount Sidekiq::Web => '/sidekiq'
  
  resources :password_resets, only: [:new, :create]

  resources :users, only: [:new, :create] do
    collection do
      get :confirm_email
    end
  end

  resources :masters do
    collection do
      get :excel_import_new
      post :import_excel
      get :export
      post :create_segment
    end
    get :index
  end

  resources :chatbots, only: [:index, :new, :create, :edit, :update, :destroy] do
    resources :chatbot_steps, only: [:index, :new, :create, :edit, :update, :destroy] do
      resources :chatbot_button_replies, only: [:new, :create, :edit, :update, :destroy]
      resources :chatbot_multimedia_replies, only: [:new, :create, :edit, :update, :destroy]
      resources :chatbot_location_replies, only: [:new, :create, :edit, :update, :destroy]
    end
  end

  resources :master_segments, only: [:index, :new, :create, :edit, :update, :destroy] do
    resources :segments, only: [:index, :new, :edit, :update, :create, :destroy]
  end

  resources :whatsapp_accounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :templates, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :broadcasts, only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      post :send_now
    end
    resources :broadcast_reports, only: [:index]
  end

  resources :conversations, only: [:index] do 
    collection do
      get :conversations_by_phone_number
      post :respond
    end
  end

  root "users#new"
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'login/user', to: 'sessions#new', as: 'login_user'

  get 'password_resets/:token/edit', to: 'password_resets#edit', as: 'edit_password_reset'
  patch 'password_resets/:token', to: 'password_resets#update', as: 'update_password_reset'
  get 'confirm_email', to: 'users#confirm_email'

  post '/webhook', to: 'webhook#receive'
  get '/webhook', to: 'webhook#verify'


end
