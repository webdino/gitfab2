Gitfab2::Application.routes.draw do
  devise_for :users, controllers: {sessions: "sessions"}
  root "home#index"
  match "search" => "global_recipes#index", via: :get
  resources :users do
    resources :recipes do
      post :fork
      resources :statuses do
        resources :ways
      end
      resources :materials
      resources :tools
    end
  end
  resources :tags
end
