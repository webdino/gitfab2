Gitfab2::Application.routes.draw do
  root "home#index"

  concern :owner do
    resources :recipes do
      resources :statuses do
        resources :ways
      end
      resources :materials
      resources :tools
      resources :usages
      resources :posts
      resources :attachments
      resources :collaborations
    end
  end

  if Rails.env.development?
    match "su" => "home#su", via: :post
  end

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  match "home" => "home#proxy_to_userhome", via: :get
  match "search" => "global_recipes#index", via: :get

  resources :tags
  resources :comments
  resources :likes
  resources :users, concerns: :owner
  resources :groups, concerns: :owner do
    resources :memberships
  end

  resources :recipes, path: "/:owner_name" do
    resources :ways, constraints: {id: /.+/}
    resources :tools, constraints: {id: /.+/}
    resources :usages, constraints: {id: /.+/}
    resources :posts, constraints: {id: /.+/}
    resources :attachments, constraints: {id: /.+/}
    resources :collaborations, constraints: {id: /.+/}
  end          
end
