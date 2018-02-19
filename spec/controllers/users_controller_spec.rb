# frozen_string_literal: true

require 'spec_helper'

describe UsersController, type: :controller do
  # render_views

  subject { response }

  let(:user) { FactoryGirl.create :user }

  describe 'GET index' do
    before { get :index }
    it { is_expected.to render_template :index }
  end

  describe 'GET edit' do
    before do
      get :edit, id: user
    end
    it { is_expected.to render_template :edit }
  end

  describe 'PATCH update' do
    before do
      patch :update, id: user, user: { name: 'foo' }
      user.reload
    end
    it { is_expected.to redirect_to edit_user_path(user) }
  end

  describe 'DELETE destroy' do
    before do
      delete :destroy, id: user
    end
    it { is_expected.to redirect_to root_path }
  end
end
