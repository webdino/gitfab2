Gitfab2::Application.routes.draw do
  root "global_projects#index"

  if Rails.env.development? || Rails.env.test?
    match "su" => "development#su", via: :post
  end

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  match "home" => "owner_projects#index", via: :get
  match "search" => "global_projects#index", via: :get

  resources :users do
    resources :collaborations
    resources :memberships
  end

  resources :groups do
    resources :members
  end

  resources :global_projects, only: :index
  resources :projects, path: "/:owner_name" do
    resource :note, only: :show do
      resources :memos
    end
    resource :recipe, only: [:show, :update] do
      resources :recipe_cards
    end
    resources :usages, constraints: {id: /.+/}
  end          

end
