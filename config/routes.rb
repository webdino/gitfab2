Gitfab2::Application.routes.draw do
  devise_for :users, controllers: {sessions: "sessions"}
  root "home#index"
  match "search" => "global_recipes#index", via: :get
  match "su" => "home#su", via: :post
  resources :users do
    resources :recipes do
      post :fork
      resources :statuses
      resources :ways
      resources :materials
      resources :tools
      resources :posts do
        resources :post_attachments
      end
    end
  end
  resources :tags
  resources :groups do
    resources :memberships
  end
end
