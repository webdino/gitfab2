module Api
  module V0
    class ProjectsController < ApplicationController
      skip_authorize_resource
      before_action :check_authorization
      before_action :load_owner
      before_action :load_project, only: [:show, :edit, :update, :destroy]
      before_action :build_project, only: [:new, :create]
      before_action :delete_collaborations, only: :destroy

      def index
        render json: @projects, status: 200
      end

      def show
        render json: @project, status: 200
      end

      def create
        slug = project_params[:title]
        slug = slug.gsub(/\W|\s/, 'x').downcase
        @project.name = slug
        if @project.save
          render json: @project, status: 200
        else
          return head 400
        end
      end

      def destroy
        @project.destroy project_params
        return head :no_content, status: 200
      end

      def edit
      end

      def update
        parameters = project_params
        if parameters.present? && parameters[:name].present?
          parameters[:name] = parameters[:name].downcase
        end
        @project.updated_at = DateTime.now.in_time_zone
        if @project.update parameters
          render json: @project, status: 200
        else
          return head 400
        end
      end

      private

      def project_params
        if params[:project]
          params.require(:project).permit(Project.updatable_columns)
        end
      end

      def build_project
        @project = @owner.projects.build project_params
      end

      def load_project
        @project = @owner.projects.find params[:id]
        not_found if @project.blank?
      end

      def load_owner
        request_auth_key = response.header['Auth-Key']
        @owner = nil
        if request_auth_key == ENV[API_AUTH_KEY_0]
          @owner = Group.find('fabmodules')
        elsif request_auth_key == ENV[API_AUTH_KEY_1]
          @owner = Group.find('fabnavi')
        end
        not_found if @owner.blank?
      end

      def check_authorization
        key_0 = ENV[API_AUTH_KEY_0]
        key_1 = ENV[API_AUTH_KEY_1]
        auth_keys = [key_0, key_1]
        request_auth_key = response.header['Auth-Key']
        if request_auth_key.present? && auth_keys.include?(request_auth_key)
          authorize! :manage, :all
        else
          return head 403
        end
      end

      def delete_collaborations
        @project.collaborators.each do |collaborator|
          collaboration = collaborator.collaborations.where('project_id' => @project.id).first
          collaboration.destroy
        end
      end
    end

  end
end
