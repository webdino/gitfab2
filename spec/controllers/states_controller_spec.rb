# frozen_string_literal: true

require 'spec_helper'

describe StatesController, type: :controller do
  render_views

  let(:project) { FactoryGirl.create :user_project }
  let(:state) { project.recipe.states.create type: Card::State.name, description: 'foo' }
  let(:new_state) { FactoryGirl.build :state }

  subject { response }

  describe 'GET new' do
    before do
      xhr :get, :new, owner_name: project.owner.name, project_id: project.name
    end
    it { expect render_template :_card_form }
  end

  describe 'GET show' do
    before do
      xhr :get, :show, owner_name: project.owner.slug, project_id: project.name, id: state.id
    end
    it { expect render_template :show, formats: :json }
  end

  describe 'GET edit' do
    before do
      xhr :get, :edit, owner_name: project.owner.name, project_id: project.name, id: state.id
    end
    it { expect render_template :edit }
  end

  describe 'POST create' do
    context 'with proper values' do
      before do
        sign_in project.owner
        xhr :post, :create, user_id: project.owner, project_id: project,
                            state: { type: Card::State.name, title: 'foo', description: 'bar' }
        project.reload
      end
      it { expect render_template :create }
      it 'has 1 state' do
        expect(project.recipe.states.size).to eq 1
      end
    end
    context 'with invalid values' do
      before do
        sign_in project.owner
        xhr :post, :create, user_id: project.owner, project_id: project,
                            state: { type: '', title: 'foo', description: 'bar' }
      end
      it { expect render_template 'error/failed' }
    end
  end

  describe 'PATCH update' do
    context 'when updating the card itself' do
      before do
        sign_in project.owner
        xhr :patch, :update, user_id: project.owner,
                             project_id: project.id, id: state.id
      end
      it { expect render_template :update }
    end
    context 'with invalid values' do
      before do
        sign_in project.owner
        xhr :patch, :update, user_id: project.owner,
                             project_id: project.id, id: state.id,
                             state: { type: '', title: 'foo', description: 'bar' }
      end
      it { expect render_template 'error/failed' }
    end
  end

  describe 'DELETE destroy' do
    context 'by who can manage the state' do
      before do
        sign_in project.owner
        xhr :delete, :destroy, owner_name: project.owner,
                               project_id: project.name, id: state.id
      end
      it { expect render_template :destroy }
    end
  end

  describe 'POST to_annotation' do
    let(:state_2) { project.recipe.states.create type: Card::State.name, description: 'bar' }
    before do
      sign_in project.owner
      xhr :post, :to_annotation, owner_name: project.owner,
                                 project_id: project.name, state_id: state_2.id, dst_state_id: state.id
      project.reload
    end
    it 'creates an annotation from a state' do
      aggregate_failures '1 state, 1 annotation' do
        expect(project.recipe.states.size).to eq 1
        expect(project.recipe.states.first.annotations.size).to eq 1
      end
    end
  end
end
