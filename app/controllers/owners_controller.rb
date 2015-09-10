class OwnersController < ApplicationController
  def index
    @owners = User.asc(:name).all + Group.asc(:name).all
  end
end
