class PostsController < ApplicationController
  before_action :load_owner
  before_action :load_recipe
  before_action :build_post, only: [:new, :create]
  before_action :load_post, only: [:show, :edit, :update, :destroy]

  layout "posts"

  authorize_resource

  def index
    @posts = @recipe.posts.page params[:page]
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @post.save
      redirect_to [@owner, @recipe, @post], notice: "Post was successfully created."
    else
      render :new
    end
  end

  def update
    if @post.update post_params
      redirect_to [@owner, @recipe, @post], notice: "Post was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to [@owner, @recipe, :posts]
  end

  private
  def load_owner
    owner_name = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = if User.exists? owner_name
      User.find owner_name
    elsif Group.exists? owner_name
      Group.find owner_name
    end
  end

  def load_recipe
    @recipe = @owner.recipes.find params[:recipe_id]
  end

  def load_post
    @post = @recipe.posts.find params[:id]
  end

  def build_post
    @post = @recipe.posts.build post_params
  end

  def post_params
    if params[:post]
      params.require(:post).permit Post::UPDATABLE_COLUMNS
    end
  end
end
