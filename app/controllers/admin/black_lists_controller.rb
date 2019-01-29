class Admin::BlackListsController < Admin::ApplicationController
  def index
    @black_lists = BlackList.order(id: :desc)
  end

  def show
    @black_list = BlackList.find(params[:id])
  end

  def new
    @black_list = BlackList.new
  end

  def create
    @black_list = BlackList.new(admin_black_list_params)

    if @black_list.save
      redirect_to admin_black_lists_url, flash: { success: "#{@black_list.project.title}をブラックリストに登録しました" }
    else
      render :new
    end
  end

  def destroy
    black_list = BlackList.find(params[:id])
    black_list.destroy
    redirect_to admin_black_lists_url, flash: { danger: "#{black_list.project.title}をブラックリストから削除しました" }
  end

  private

    def admin_black_list_params
      params.require(:black_list).permit(:project_id, :reason).merge(user: current_user)
    end
end
