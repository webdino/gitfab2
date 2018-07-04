class Admin::FeaturesController < Admin::ApplicationController
  before_action :load_feature, only: [:show, :update, :destroy]

  #  authorize_resource

  def index
    @features = Feature.all
  end

  def create
    @feature = Feature.new feature_params
    if @feature.save
      render :create
    else
      render json: { success: false }, status: 400
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
    params.require(:feature).permit(Feature.updatable_columns)
  end
end
