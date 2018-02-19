# frozen_string_literal: true

require 'spec_helper'

describe CollaboratorsController, type: :controller do
  render_views

  subject { response }

  let(:project) { FactoryGirl.create :user_project }
  let(:user) { FactoryGirl.create :user }
  let(:user_2) { FactoryGirl.create :user }

  describe 'GET index' do
    before { get :index, owner_name: project.owner.name, project_id: project }
    it { is_expected.to render_template :index }
  end

  describe 'POST create' do
    context 'for user project' do
      context 'with valid parameters' do
        before do
          sign_in project.owner
          xhr :post, :create, user_id: project.owner, project_id: project, collaborator_name: user_2.slug
        end
        it { is_expected.to render_template :create }
      end
      context 'with invalid parameters' do
        before do
          sign_in project.owner
          xhr :post, :create, user_id: project.owner, project_id: project, collaborator_name: 'unknownuser'
        end
        it { expect render_template 'errors/failed', status: 400 }
      end
    end
  end
end
