class StatusesController < ItemsController
  authorize_resource :status
end
