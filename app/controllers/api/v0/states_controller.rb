module Api
  module V0
    class StatesController < ApplicationController
      skip_authorize_resource
      before_action :check_authorization
      before_action :load_owner
      before_action :load_project
      before_action :load_recipe
      before_action :build_state, only: [:new, :create]
      before_action :load_state, only: [:edit, :show, :update, :destroy]
      before_action :update_contribution, only: [:create, :update]
      after_action :update_project, only: [:create, :update, :destroy]

      def new
      end

      def edit
      end

      def show
        render json: @state, status: 200
      end

      def create
        if @state.save
          render json: @state, status: 200
        else
          return head 400
        end
      end

      def update
        if @state.update state_params
          render json: @state, status: 200
        else
          return head 400
        end
      end

      def destroy
        if @state.destroy
          return head :no_content, status: 200
        else
          return head 400
        end
      end

      private

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

      def load_project
        @project = @owner.projects.find params[:project_id]
        not_found if @project.blank?
      end

      def load_recipe
        @recipe = @project.recipe
      end

      def load_state
        @state ||= @recipe.states.find(params[:id])
        not_found if @state.blank?
      end

      def build_state
        @state = @recipe.states.build state_params
      end

      def state_params
        if params[:state]
          params.require(:state).permit Card::State.updatable_columns
        end
      end

      def update_contribution
        return unless @owner
        @state.contributions.each do |contribution|
          if contribution.contributor_id == @owner.slug
            contribution.updated_at = DateTime.now.in_time_zone
            contribution.save
            return
          end
        end
        contribution = @state.contributions.new
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

    end
  end
end
