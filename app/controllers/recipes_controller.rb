class RecipesController < ApplicationController
  layout "recipe"

  before_action :load_owner
  before_action :build_recipe, only: [:new, :create]
  before_action :load_recipe, only: [:show, :edit, :update, :destroy]
  before_action :set_last_committer, only: [:create, :update]
  after_action :commit, only: [:create, :update], unless: ->{@recipe.errors.any? || params[:base_recipe_id]}

  authorize_resource

  def index
    if q = params[:q]
      @recipes = @owner.recipes.solr_search do
        fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        case params[:type]
        when "own"
          with :owner_id, params[:user_id]
        when "contributed"
          # TODO: Implement
        when "starred"
          # TODO: Implement
        end
      end.results
    else
      @recipes = @owner.recipes
    end
    render layout: "dashboard"
  end

  def show
  end

  def new
    @recipe.fill_default_name_for! @owner
  end

  def edit
  end

  def create
    if params[:base_recipe_id]
      self.fork
    else
      if @recipe.save
        redirect_to recipe_path(id: @recipe.name, owner_name: @recipe.owner.name), notice: "Recipe was successfully created."
      else
        render action: :new
      end
    end
  end

  def fork
    base_recipe = Recipe.find params[:base_recipe_id]
    @recipe = base_recipe.fork_for! @owner
    if @recipe.save
      redirect_to recipe_path(id: @recipe.name, owner_name: @owner.name), notice: "Recipe was successfully forked."
    else
      raise "error"
      render action: :new
    end
  end

  def update
    if @recipe.update recipe_params
      redirect_to recipe_path(id: @recipe.name, owner_name: @owner.name), notice: "Recipe was successfully updated."
    else
      render action: :edit
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path owner_name: @owner.name
  end

  private
  def build_recipe
    @recipe = @owner.recipes.build recipe_params
  end

  def load_recipe
    recipe_id = params[:id] || params[:recipe_id]
    @recipe = @owner.recipes.find recipe_id
  end

  def load_owner
    if params[:owner_name]
      @owner ||= User.find_by slug: params[:owner_name]
      @owner ||= Group.find_by slug: params[:owner_name]
    elsif params[:user_id]
      @owner = User.find params[:user_id]
    elsif params[:group_id]
      @owner = Group.find params[:group_id]
    end
  end

  def recipe_params
    if params[:recipe]
      params_for_tools     = Tool::UPDATABLE_COLUMNS   + [:id, :_destroy]
      params_for_usages    = Usage::UPDATABLE_COLUMNS  + [:id, :_destroy]
      params_for_materials = Tool::UPDATABLE_COLUMNS   + [:id, :_destroy]
      params_for_ways      = Way::UPDATABLE_COLUMNS    + [:id, :_destroy]
      params_for_statuses  = Status::UPDATABLE_COLUMNS + [:id, :_destroy, ways_attributes: params_for_ways]

      params.require(:recipe)
        .permit Recipe::UPDATABLE_COLUMNS + [
          tools_attributes: params_for_tools,
          usages_attributes: params_for_usages,
          statuses_attributes: params_for_statuses
        ]
    end
  end

  def commit
    @recipe.commit!
  end

  def set_last_committer
    @recipe.last_committer = current_user
  end

end
