Gitfab2::Application.routes.draw do
  devise_for :users, controllers: {sessions: "sessions"}
  root "home#index"
  match "search" => "recipes#search", via: :get
  resources :users do
    resources :recipes do
      post :fork
      resources :statuses
      resources :ways
      resources :materials
      resources :tools
    end
  end
  resources :tags
end
