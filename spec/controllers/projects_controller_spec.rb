# frozen_string_literal: true

describe ProjectsController, type: :controller do
  render_views

  subject { response }

  let(:user_project) { FactoryBot.create :user_project }
  let(:group_project) { FactoryBot.create :group_project }

  %w[user group].each do |owner_type|
    let(:project) { send "#{owner_type}_project" }
    context "with a project owned by a #{owner_type}" do
      describe 'GET show' do
        before do
          get :show, params: { owner_name: project.owner.slug, id: project.name }
        end
        it { is_expected.to render_template 'projects/show' }
      end
      describe 'GET new' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :new
        end
        it { is_expected.to render_template :new }
      end
      describe 'DELETE destroy' do
        context 'without collaborators' do
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
            delete :destroy, params: { owner_name: project.owner.slug, id: project.id }
          end
          it { is_expected.to redirect_to owner_path(owner_name: project.owner.slug) }
        end
        context 'with collaborators' do
          let(:user) { FactoryBot.create :user }
          let(:group) { FactoryBot.create :group }
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
            user.collaborations.create project_id: project
            group.collaborations.create project_id: project
            delete :destroy, params: { owner_name: project.owner.slug, id: project.id }
            user.reload
            group.reload
          end
          it { is_expected.to redirect_to owner_path(owner_name: project.owner.slug) }
          it 'has 0 collaborations' do
            aggregate_failures do
              expect(user.collaborations.size).to eq 0
              expect(group.collaborations.size).to eq 0
            end
          end
        end
      end
      describe 'GET edit' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :edit, params: { owner_name: project.owner.slug, id: project.id }
        end
        it { is_expected.to render_template :edit }
      end
      describe 'POST create' do
        context 'when newly creating' do
          let(:user) { FactoryBot.create :user }
          let(:new_project) { FactoryBot.build(:user_project, original: nil) }
          before do
            sign_in user
            post :create, params: { project: new_project.attributes.merge(owner_id: user.slug) }
          end
          it { is_expected.to redirect_to(edit_project_path(id: assigns(:project), owner_name: user)) }
        end
        context 'when newly creating with wrong parameters' do
          let(:user) { FactoryBot.create :user }
          let(:new_project) { FactoryBot.build(:user_project, original: nil) }
          before do
            sign_in user
            wrong_parameters = new_project.attributes
            wrong_parameters['title'] = ''
            post :create, params: { project: wrong_parameters.merge(owner_id: user.slug) }
          end
          it { is_expected.to render_template :new }
        end
      end

      describe 'GET recipe_cards_list' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner
          sign_in user_project.owner
          get :recipe_cards_list, params: { owner_name: project.owner, project_id: project }, xhr: true
        end
        it { is_expected.to render_template 'recipe_cards_list' }
      end

      describe 'PATCH update' do
        subject { patch :update, params: params }

        let(:params) { { owner_name: project.owner, id: project.id, project: project_params } }

        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
        end

        context 'success' do
          let(:project_params) { { description: '_proj' } }
          it { is_expected.to redirect_to project_path(owner_name: project.owner, id: project) }
        end

        context 'raising error by invalid title' do
          let(:project_params) { { title: '' } }
          it { is_expected.to render_template :edit }
        end
      end
    end
  end

  describe 'POST #fork' do
    subject { post :fork, params: { owner_name: project.owner, project_id: project, owner_id: target_owner.slug } }
    let(:target_owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    before { sign_in target_owner }
    it { is_expected.to redirect_to project_path(target_owner, Project.last) }
    it { expect{ subject }.to change{ Project.count }.by(1) }
  end
end
