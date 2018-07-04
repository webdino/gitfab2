class Admin::FeaturedItemsController < Admin::ApplicationController
  before_action :load_item, only: [:show, :destroy]
  before_action :load_feature, only: [:create, :update, :destroy]

  #  authorize_resource

  def index
    @item = @featured_items.all
  end

  def create
    @item = @feature.featured_items.build item_params
    @item.feature_id = params[:feature_id]
    if @item.save
      render :create
    else
      render json: { success: false }, status: 400
    end
  end

  def destroy
    @item.destroy
    render body: nil
  end

  private

  def load_feature
    @feature = Feature.find params[:feature_id]
  end

  def load_item
    @item = FeaturedItem.find params[:id]
  end

  def item_params
    if params[:featured_item]
      params.require(:featured_item).permit(FeaturedItem.updatable_columns)
    end
  end
end
