class GlobalProjectsController < ApplicationController
  layout "global_projects"

  def index
    if q = params[:q]
      @projects = Project.solr_search do |s|
        s.fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        s.without :is_private, true
      end.results
    else
      @projects = Project.all().in(is_private: [false, nil]).order("updated_at DESC")
    end      
  end
end
