Gitfab2::Application.routes.draw do
  match 'about' => 'static_pages#about', via: :get
  match 'terms' => 'static_pages#terms', via: :get
  match 'privacy' => 'static_pages#privacy', via: :get

  namespace :admin do
    root 'dashboard#index'
    resources :features do
      resources :featured_items
    end
    resources :projects, via: %i(get put delete)
    get 'background' => 'background#index', as: :background
    put 'background' => 'background#update'
  end

  root 'global_projects#index'

  if Rails.env.development? || Rails.env.test?
    match 'su' => 'development#su', via: :post
  end

  get '/users/auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  match 'home' => 'owner_projects#index', via: :get
  match 'search' => 'global_projects#index', via: :get

  concern :card_features_for_form do
    resources :annotations, only: [:create, :update], concerns: :comments
    resources :derivative_cards, only: [:create, :update]
  end

  concern :card_features_for_link do
    resources :annotations, except: [:create, :update]
    resources :annotations do
      get 'to_state'
    end
    resources :derivative_cards, except: [:create, :update]
  end

  concern :comments do
    resources :comments, only: [:create, :destroy]
  end

  concern :tags do
    resources :tags, only: [:create, :destroy]
  end

  resources :owners, only: [:index]

  concern :owner do
    resources :projects do
      get 'potential_owners'
      get 'recipe_cards_list'
      get 'relation_tree'
    end
    resources :projects, only: [:create, :update], concerns: :tags do
      resources :collaborators, only: [:create, :update]
      resource :recipe, only: :update do
        resources :states, only: [:create, :update], concerns: [:card_features_for_form, :comments]
      end
      resources :note_cards, only: [:create, :update], concerns: :comments
      resources :usages, only: [:create, :update]
    end
  end

  resources :users, concerns: :owner do
    resources :collaborations
    resources :memberships
    resources :notifications do
      get 'mark_all_as_read', on: :collection
    end
  end

  resources :groups, concerns: :owner do
    resources :collaborations
    resources :members
  end

  resources :global_projects, only: :index

  resources :projects, path: '/:owner_name', except: [:create, :update] do
    resources :collaborators, except: [:create, :update]
    resources :note_cards, except: [:create, :update]
    resource :recipe, only: :show do
      resources :states, except: [:create, :update], concerns: :card_features_for_link
      resources :states do
        get 'to_annotation'
      end
    end
    resources :usages, constraints: { id: /.+/ }, except: [:create, :update]
  end
end
