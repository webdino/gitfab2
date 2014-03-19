class GlobalRecipesController < ApplicationController
  def index
    q = params[:q] || ""
    @recipes = Recipe.solr_search do
      fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
    end.results
  end
end
