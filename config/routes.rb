Gitfab2::Application.routes.draw do
  root "global_projects#index"

  if Rails.env.development? || Rails.env.test?
    match "su" => "development#su", via: :post
  end

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  match "home" => "owner_projects#index", via: :get
  match "search" => "global_projects#index", via: :get

  concern :owner do
    resources :projects, only: [:create, :update] do
      resource :recipe, only: [:update] do
        resources :recipe_cards do
          resources :annotations
          resources :derivative_cards
        end
      end
      resource :note, only: [] do
        resources :note_cards
      end
    end
  end

  resources :users, concerns: :owner do
    resources :collaborations
    resources :memberships
  end

  resources :groups, concerns: :owner do
    resources :members
  end

  resources :global_projects, only: :index
  resources :projects, path: "/:owner_name" do
    resources :collaborators
    resource :note, only: :show do
      resources :note_cards do
        resources :annotations
        resources :derivative_cards
      end
    end
    resource :recipe, only: [:show, :update] do
      resources :recipe_cards
    end
    resources :usages, constraints: {id: /.+/}
  end          
end
