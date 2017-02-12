class OwnersController < ApplicationController
  def index
    @owners = User.order(name: :asc).all + Group.order(name: :asc).all
  end
end
