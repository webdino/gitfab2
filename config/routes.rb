Gitfab2::Application.routes.draw do
  devise_for :users, controllers: {sessions: "sessions"}
  root "home#index"
end
