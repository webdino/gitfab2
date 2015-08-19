module Gitfab2
  class API < Grape::API
    version 'v1', using: :path, vendor: "fabble"
    format :json
    prefix :api

    helpers do
      def current_user
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resources :global_projects, only: :index
    resources :projects do

    end
  end
end
