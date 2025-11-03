Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Stub Vite dev client to avoid routing errors in environments without Vite
  get "/@vite/client", to: proc { [200, { "Content-Type" => "application/javascript" }, ["// Vite client disabled in this environment\n"]] }

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication endpoints
      post 'register', to: 'users#register'
      post 'login', to: 'users#login'

      # Job Application Screening Service endpoints
      post 'upload', to: 'documents#upload'
      post 'evaluate', to: 'evaluations#create'
      get 'result/:id', to: 'evaluations#show'

      # Additional endpoints for managing reference documents
      resources :job_descriptions, only: [:create, :index, :show, :destroy]
      resources :case_studies, only: [:create, :index, :show, :destroy]
      resources :scoring_rubrics, only: [:create, :index, :show, :destroy]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
