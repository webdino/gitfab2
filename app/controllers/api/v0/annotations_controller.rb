module Api
  module V0
    class AnnotationsController < ApplicationController
      protect_from_forgery :except => [:index, :show, :create, :destroy, :edit, :update]
      skip_authorize_resource
      before_action :check_authorization
      before_action :load_owner
      before_action :load_project
      before_action :load_recipe
      before_action :load_state
      before_action :load_annotation, only: [:edit, :show, :update, :destroy]
      before_action :build_annotation, only: [:new, :create]
      before_action :update_contribution, only: [:create, :update]
      after_action :update_project, only: [:create, :update, :destroy]

      def index
        @annotations = @state.annotations
        render :index, format: 'json'
      end

      def new
      end

      def edit
      end

      def show
        load_prev
        load_next
        render :show, format: 'json'
      end

      def create
        if @annotation.save
          load_prev
          load_next
          render :show, format: 'json'
        else
          return head 400, format: 'json'
        end
      end

      def update
        if @annotation.update annotation_params
          load_prev
          load_next
          render :show, format: 'json'
        else
          return head 400, format: 'json'
        end
      end

      def destroy
        if @annotation.destroy
          return head :no_content, status: 200, format: 'json'
        else
          return head 400, format: 'json'
        end
      end

      private

      def load_owner
        request_auth_key = request.headers['HTTP_X_AUTH_KEY']
        @owner = nil
        if request_auth_key == ENV['API_AUTH_KEY_0']
          @owner = Group.find('fabmodules')
        elsif request_auth_key == ENV['API_AUTH_KEY_1']
          @owner = Group.find('fabnavi')
        end
        not_found if @owner.blank?
      end

      def load_project
        @project = @owner.projects.find params[:project_id]
        not_found if @project.blank?
      end

      def load_recipe
        @recipe = @project.recipe
      end

      def load_state
        if params['state_id']
          @state = @recipe.states.find params['state_id']
          not_found if @state.blank?
        end
      end

      def load_annotation
        @annotation ||= @state.annotations.find params[:id]
        not_found if @annotation.blank?
      end

      def build_annotation
        @annotation = @state.annotations.build annotation_params
      end

      def annotation_params
        if params[:annotation]
          params.require(:annotation).permit Card::Annotation.updatable_columns
        end
      end

      def update_contribution
        return unless @owner
        @annotation.contributions.each do |contribution|
          if contribution.contributor_id == @owner.slug
            contribution.updated_at = DateTime.now.in_time_zone
            contribution.save
            return
          end
        end
        contribution = @annotation.contributions.new
        contribution.contributor_id = @owner.slug
        contribution.created_at = DateTime.now.in_time_zone
        contribution.updated_at = DateTime.now.in_time_zone
        contribution.save
      end

      def update_project
        return unless @_response.response_code == 200
        @project.updated_at = DateTime.now.in_time_zone
        @project.update
      end

      def check_authorization
        key_0 = ENV['API_AUTH_KEY_0']
        key_1 = ENV['API_AUTH_KEY_1']
        auth_keys = [key_0, key_1]
        request_auth_key = request.headers['HTTP_X_AUTH_KEY']
        unless request_auth_key.present? && auth_keys.include?(request_auth_key)
          return head 403
        end
      end

      def load_prev
        prev_position = @annotation.position - 1
        @prev = prev_position <= 0 ? nil : @state.annotations.where(position: prev_position).first
      end

      def load_next
        next_position = @annotation.position + 1
        @next = next_position > @state.annotations.length ? nil : @state.annotations.where(position: next_position).first
      end

    end
  end
end
