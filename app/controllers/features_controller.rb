class FeaturesController < ApplicationController
  layout "dashboard"

  before_action :load_feature, only: [:show, :update, :destroy]

#  authorize_resource

  def index
    @features = Feature.all
    if signed_in? && current_user.is_system_admin?
      @features
    else
      redirect_to root_path
    end
  end

  def create
    @feature = Feature.new feature_params
    if @feature.save
      render :create
    else
      render "errors/failed", status: 400
    end
  end

  def update
  end

  def show
  end

  def destroy
    @feature.destroy
  end

  private
  def load_feature
    @feature = Feature.find params[:id]
  end

  def feature_params
    params.require(:feature).permit (Feature.updatable_columns)
  end

end
