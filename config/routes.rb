Rails.application.routes.draw do
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

  resources :sessions, only: [:index, :create]
  get '/users/auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  match 'home' => 'owner_projects#index', via: :get
  match 'search' => 'global_projects#index', via: :get

  resources :cards, only: [] do
    resources :card_comments, only: :create
  end
  resources :card_comments, only: :destroy

  resources :groups do
    resources :members
  end

  resources :owners, only: [:index]
  resource :owners, path: '/:owner_name', as: :owner, only: :show

  resources :users, except: :show do
    resources :memberships, only: [:index, :destroy]
    resources :notifications do
      get 'mark_all_as_read', on: :collection
    end
    patch :update_password
  end

  resources :global_projects, only: :index

  resources :collaborations, only: :destroy
  resources :projects, only: [:new, :create]
  resources :tags, only: :destroy
  resources :projects, path: '/:owner_name', except: [:index, :new, :create] do
    resources :collaborations, only: :create
    resources :note_cards
    resource :recipe, only: :update do
      resources :states, except: :index do
        resources :annotations, except: :index do
          get 'to_state'
        end
        get 'to_annotation'
      end
    end
    resources :tags, only: :create
    resources :usages, only: [:new, :create, :edit, :update, :destroy]
    resources :project_comments, only: [:create, :destroy]
    post :fork
    get 'recipe_cards_list'
    get 'relation_tree'
  end
end
