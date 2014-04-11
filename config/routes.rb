Gitfab2::Application.routes.draw do
  concern :owner do
    resources :recipes do
      resources :statuses
      resources :ways
      resources :materials
      resources :tools
      resources :usages
      resources :posts
      resources :post_attachments
      resources :collaborations
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

  resources :recipes, except: [:new, :create, :index], path: "/:owner_name" do
    resources :statuses, constraints: {id: /.+/}
    resources :ways, constraints: {id: /.+/}
    resources :materials, constraints: {id: /.+/}
    resources :tools, constraints: {id: /.+/}
    resources :usages, constraints: {id: /.+/}
    resources :posts, constraints: {id: /.+/}
    resources :post_attachments, constraints: {id: /.+/}
    resources :collaborations, constraints: {id: /.+/}
  end          
end
