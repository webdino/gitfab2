Gitfab2::Application.routes.draw do
  concern :owner do
    resources :recipes do
      resources :statuses
      resources :ways
      resources :materials
      resources :tools
      resources :posts
      resources :post_attachments
    end
  end

  if Rails.env.development?
    match "su" => "home#su", via: :post
  end

  devise_for :users, controllers: {sessions: "sessions"}
  root "home#index"
  match "search" => "global_recipes#index", via: :get

  resources :tags
  resources :users, concerns: :owner
  resources :groups, concerns: :owner do
    resources :memberships
  end
end
