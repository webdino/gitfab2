Rails.application.routes.draw do
  get 'about', to: 'static_pages#about'
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'

  namespace :admin do
    root 'dashboard#index'
    resources :features do
      resources :featured_items
    end
    resources :projects, via: %i(get put delete)
    get 'background', to: 'background#index', as: :background
    put 'background', to: 'background#update'
  end

  root 'projects#index'

  if Rails.env.development? || Rails.env.test?
    post 'su', to: 'development#su'
  end

  resources :sessions, only: [:index, :create]
  get '/users/auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get 'search', to: 'projects#search'

  resources :cards, only: [] do
    resources :card_comments, only: :create
  end
  resources :card_comments, only: :destroy

  resources :groups, except: :show do
    resources :members
  end

  resources :users, except: :show do
    resources :memberships, only: [:index, :destroy]
    resources :notifications do
      get 'mark_all_as_read', on: :collection
    end
    patch :update_password
  end

  resources :collaborations, only: :destroy
  resources :projects, only: [:new, :create]
  resources :tags, only: :destroy
  resources :projects, path: '/:owner_name', except: [:index, :new, :create, :search] do
    resources :collaborations, only: :create
    resources :note_cards
    resources :states, except: :index do
      resources :annotations, except: :index do
        get 'to_state'
      end
      get 'to_annotation'
    end
    resources :tags, only: :create
    resources :usages, only: [:new, :create, :edit, :update, :destroy]
    resources :project_comments, only: [:create, :destroy]
    post :fork
    patch :change_order
    get 'recipe_cards_list'
    get 'relation_tree'
  end

  resources :owners, only: :index
  resource :owners, path: '/:owner_name', as: :owner, only: :show
end
