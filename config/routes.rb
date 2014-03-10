Gitfab2::Application.routes.draw do
  resources :recipes

  devise_for :"users", controllers: {sessions: "sessions"}
  root "home#index"
  resources :owners do
    resources :recipes
  end
end
