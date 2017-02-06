class Admin::BackgroundController < ApplicationController
  include Administration
  layout 'dashboard'

  def index
    @background_image = BackgroundImage.find
  end

  def update
    @background_image = BackgroundImage.new(file: params[:file])

    if @background_image.save
      redirect_to action: :index
    else
      @background_image.file = nil
      render action: :index, status: :unprocessable_entity
    end
  end
end
