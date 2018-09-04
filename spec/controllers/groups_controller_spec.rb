# frozen_string_literal: true

describe GroupsController, type: :controller do
  render_views

  let(:user) { FactoryBot.create :user }
  let(:other) { FactoryBot.create :user }
  let(:group) { FactoryBot.create :group }

  subject { response }

  describe 'GET index' do
    before do
      sign_in user
      get :index
    end
    it { is_expected.to render_template :index }
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
      post :create, params: { group: group_params }
    end
    context 'with valid params' do
      let(:group_params) { FactoryBot.build(:group).attributes }
      it { is_expected.to redirect_to(edit_group_url(assigns(:group))) }
    end
    context 'with invalid params' do
      let(:group_params) { { name: nil } }
      it { is_expected.to render_template :new }
    end
  end

  describe 'GET edit' do
    subject { get :edit, params: { id: group } }

    describe 'as an admin' do
      before do
        user.memberships.create(group: group, role: 'admin')
        sign_in user
      end

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template :edit }
    end

    describe 'as an editor' do
      before do
        user.memberships.create(group: group, role: 'admin')
        sign_in other
        other.memberships.create(group: group, role: 'editor')
      end

      it { is_expected.to have_http_status :forbidden }
    end
  end

  describe 'PATCH update' do
    subject { patch :update, params: { id: group, group: group_params } }

    describe 'as an admin' do
      before do
        sign_in user
        user.memberships.create(group_id: group.id, role: 'admin')
      end

      context 'with valid params' do
        let(:group_params) { { name: 'updated' } }

        it { is_expected.to have_http_status :redirect }
        it 'updates a group' do
          expect { subject }.to change { group.reload.name }
        end
      end

      context 'with invalid params' do
        let(:group_params) { { name: nil } }

        it { is_expected.to have_http_status :success }
        it { is_expected.to render_template :edit }
        it 'does NOT update a group' do
          expect { subject }.not_to change { group.reload.name }
        end
      end
    end

    describe 'as an editor' do
      let(:group_params) { { name: 'updated' } }

      before do
        user.memberships.create(group: group, role: 'admin')
        sign_in other
        other.memberships.create(group: group, role: 'editor')
      end

      it 'does NOT update a group' do
        expect { subject }.not_to change { group.reload.name }
      end

      it { is_expected.to have_http_status :forbidden }
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: group } }
    before { user.memberships.create(group_id: group.id, role: 'admin') }

    describe 'as an admin' do
      let!(:group) { FactoryBot.create :group }

      before { sign_in user }

      it { is_expected.to have_http_status :redirect }
      it { expect { subject }.to change { group.reload.is_deleted }.from(false).to(true) }
    end

    describe 'as an editor' do
      before do
        sign_in other
        other.memberships.create(group_id: group.id, role: 'editor')
      end

      it { is_expected.to have_http_status :forbidden }
      it { expect { subject }.not_to change { group.reload.is_deleted } }
    end

    describe 'collaborations' do
      before do
        sign_in user
        FactoryBot.create_list(:collaboration, 2, owner: group)
      end

      it { expect { subject }.to change { Collaboration.count }.to(0) }
    end

    describe 'projects' do
      before do
        sign_in user
        FactoryBot.create_list(:project, 2, owner: group)
      end

      context 'when a group has projects' do
        it { is_expected.to redirect_to [:edit, group] }
        it { expect { subject }.not_to change { group.reload.is_deleted } }
      end

      context 'when a group has NO projects' do
        before { group.projects.destroy_all }
        it { is_expected.to redirect_to :groups }
        it { expect { subject }.to change { group.reload.is_deleted }.from(false).to(true) }
      end

      context 'when projects are soft deleted' do
        before { group.projects.update_all(is_deleted: true) }
        it { is_expected.to redirect_to :groups }
        it { expect { subject }.to change { group.reload.is_deleted }.from(false).to(true) }
      end
    end

    describe 'raise on soft_destroy!' do
      before do
        sign_in user
        FactoryBot.create_list(:collaboration, 2, owner: group)
        allow_any_instance_of(Group).to receive(:soft_destroy!).and_raise(error)
      end

      shared_examples_for 'rescue' do
        it { is_expected.to redirect_to [:edit, group] }
        it { expect { subject }.not_to change { group.reload.is_deleted } }
        it { expect { subject }.not_to change { Collaboration.count } }
      end

      describe 'ActiveRecord::RecordNotSaved' do
        let(:error) { ActiveRecord::RecordNotSaved }
        include_examples 'rescue'
      end

      describe 'ActiveRecord::RecordNotDestroyed' do
        let(:error) { ActiveRecord::RecordNotDestroyed }
        include_examples 'rescue'
      end
    end
  end
end
