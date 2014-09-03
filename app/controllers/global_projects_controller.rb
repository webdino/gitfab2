class GlobalProjectsController < ApplicationController
  layout "global_projects"

  def index
    q = params[:q]

    if q.present?
      @projects = Project.solr_search do |s|
        s.fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        s.without :is_private, true
      end.results
      @is_searching = true

    elsif !q.nil?
      @projects = Project.all().in(is_private: [false, nil]).page(params[:page]).order("updated_at DESC")
      @is_searching = true

    else
      @projects = Project.all().in(is_private: [false, nil]).page(params[:page]).order("updated_at DESC")
      @featured_projects = []
      config = YAML.load_file("#{Rails.root}/config/sample-projects.yml")
      if config
        config.each do |id|
          project = Project.find(id)
          if project
            @featured_projects << project
          end
        end
      end
      @is_searching = false
    end
  end
end
