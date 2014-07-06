Gitfab2::Application.routes.draw do
  root "global_projects#index"

  if Rails.env.development? || Rails.env.test?
    match "su" => "development#su", via: :post
  end

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  match "home" => "owner_projects#index", via: :get
  match "search" => "global_projects#index", via: :get

  concern :card_features_for_form do
    resources :annotations, only: [:create, :update]
    resources :derivative_cards, only: [:create, :update]
  end

  concern :card_features_for_link do
    resources :annotations, except: [:create, :update]
    resources :derivative_cards, except: [:create, :update]
  end

  concern :owner do
    resources :projects, only: [:create, :update] do
      resources :collaborators, only: [:create, :update]
      resource :recipe, only: :update do
        resources :states, only: [:create, :update], concerns: :card_features_for_form
        resources :transitions, only: [:create, :update], concerns: :card_features_for_form
      end
      resource :note, only: :update do
        resources :note_cards, only: [:create, :update]
      end
      resources :usages, only: [:create, :update]
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
  resources :projects, path: "/:owner_name", except: [:create, :update] do
    resources :collaborators, except: [:create, :update]
    resource :note, only: :show do
      resources :note_cards, except: [:create, :update]
    end
    resource :recipe, only: :show do
      resources :states, except: [:create, :update], concerns: :card_features_for_link
      resources :transitions, except: [:create, :update], concerns: :card_features_for_link
    end
    resources :usages, constraints: {id: /.+/}, except: [:create, :update]
  end
end
