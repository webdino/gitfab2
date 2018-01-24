# frozen_string_literal: true

require 'spec_helper'

describe UsagesController, type: :controller do
  render_views

  let(:project) { FactoryGirl.create :user_project }
  let(:owner) { project.owner }
  let(:new_usage) { FactoryGirl.build :usage }

  subject { response }

  describe 'GET new' do
    before do
      sign_in owner
      xhr :get, :new, owner_name: owner.to_param, project_id: project
    end
    it { is_expected.to render_template :new }
  end

  describe 'GET edit' do
    before do
      sign_in owner
      usage = FactoryGirl.create :usage, project: project
      xhr :get, :edit, owner_name: owner.to_param, project_id: project,
                       id: usage.id
    end
    it { is_expected.to render_template :edit }
  end

  describe 'POST create' do
    before do
      sign_in owner
      project.usages.destroy_all
      xhr :post, :create, user_id: owner.to_param,
                          project_id: project.name, usage: { title: 'title' }
      project.reload
    end
    it { is_expected.to render_template :create }
    it { expect(project).to have(1).usage }
  end

  describe 'PATCH update' do
    before do
      sign_in owner
      usage = FactoryGirl.create :usage, project: project,
                                         title: 'foo', description: 'bar'
      xhr :patch, :update, user_id: owner.to_param,
                           project_id: project, id: usage.id, usage: { title: 'title' }
    end
    it { is_expected.to render_template :update }
  end

  describe 'DELETE destroy' do
    before do
      sign_in owner
      usage = FactoryGirl.create :usage, project: project,
                                         title: 'foo', description: 'bar'
      xhr :delete, :destroy, owner_name: owner.to_param,
                             project_id: project, id: usage.id
    end
    it { is_expected.to render_template :destroy }
  end
end
