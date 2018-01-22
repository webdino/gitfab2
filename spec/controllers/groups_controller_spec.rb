# frozen_string_literal: true

require 'spec_helper'

describe GroupsController, type: :controller do
  render_views

  let(:user) { FactoryGirl.create :user }
  let(:other) { FactoryGirl.create :user }
  let(:group) { FactoryGirl.create :group }

  subject { response }

  describe 'GET index' do
    before do
      sign_in user
      get :index
    end
    it { is_expected.to render_template :index }
  end

  describe 'GET show' do
    before do
      sign_in user
      user.memberships.create group_id: group.id
      get :show, id: group.id
    end
    it { is_expected.to render_template :show }
  end

  describe 'GET new' do
    before do
      sign_in user
      get :new
    end
    it { is_expected.to render_template :new }
  end

  describe 'POST create' do
    before do
      sign_in user
      post :create, group: group_params
    end
    context 'with valid params' do
      let(:group_params) { FactoryGirl.build(:group).attributes }
      it { is_expected.to redirect_to(edit_group_url(assigns(:group))) }
    end
    context 'with invalid params' do
      let(:group_params) { { name: nil } }
      it { is_expected.to render_template :new }
    end
  end

  describe 'GET edit' do
    before do
      sign_in user
      user.memberships.create group_id: group.id
      get :edit, id: group.id
    end
    it { is_expected.to render_template :edit }
  end

  describe 'PATCH update' do
    let(:group_params) { { name: 'updated' } }
    describe 'as an admin' do
      before do
        sign_in user
        user.memberships.create group_id: group.id
        patch :update, id: group.id, group: group_params
      end
      context 'with valid params' do
        it_behaves_like 'redirected'
      end
      context 'with invalid params' do
        let(:group_params) { { name: nil } }
        it_behaves_like 'success'
        it_behaves_like 'render template', 'edit'
      end
    end
    describe 'as an editor' do
      before do
        user.memberships.create group_id: group.id
        @orig_group = group.dup
        sign_in other
        other.memberships.create group_id: group.id
        patch :update, id: group.id, group: group_params
      end
      it_behaves_like 'unauthorized'
    end
  end

  describe 'DELETE destroy' do
    describe 'as an admin' do
      before do
        sign_in user
        user.memberships.create group_id: group.id
        delete :destroy, id: group.id
      end
      it_behaves_like 'redirected'
    end
    describe 'as an editor' do
      before do
        sign_in other
        user.memberships.create group_id: group.id
        other.memberships.create group_id: group.id
        delete :destroy, id: group.id
      end
      it_behaves_like 'unauthorized'
    end
  end
end
