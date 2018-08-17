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
          get :new, params: { owner_name: project.owner.slug, id: project.id }
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
      describe 'GET potential_owners' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          if owner_type == 'user'
            get :potential_owners, params: { user_id: project.owner.slug, project_id: project.slug }, xhr: true
          else
            get :potential_owners, params: { group_id: project.owner.slug, project_id: project.slug }, xhr: true
          end
        end
        it { is_expected.to render_template 'potential_owners' }
      end
      describe 'GET recipe_cards_list' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner
          sign_in user_project.owner
          if owner_type == 'user'
            get :recipe_cards_list, params: { user_id: project.owner, project_id: project }, xhr: true
          else
            get :recipe_cards_list, params: { group_id: project.owner, project_id: project }, xhr: true
          end
        end
        it { is_expected.to render_template 'recipe_cards_list' }
      end

      describe 'PATCH update' do
        subject { patch :update, params: params, xhr: xhr }
        let(:xhr) { false }

        context 'transfering project ownership by #change_owner' do
          let(:params) { { owner_name: project.owner, id: project, new_owner_name: owner } }

          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
          end

          context 'to user' do
            let(:owner) do
              FactoryBot.create(:user) do |user|
                user.collaborations.create(project_id: project.id)
              end
            end
            it { is_expected.to redirect_to owner_path(owner_name: owner.slug) }
            it 'has 0 collaborations' do
              subject
              expect(owner.collaborations.size).to eq 0
            end
            specify 'group is no longer a collaborator' do
              subject
              expect(owner.is_collaborator_of?(project)).to eq false
            end
          end

          context 'to group' do
            let!(:owner) do
              FactoryBot.create(:group) do |group|
                group.collaborations.create(project_id: project.id)
              end
            end
            it { is_expected.to redirect_to owner_path(owner_name: owner) }
            it 'has 0 collaborations' do
              subject
              expect(owner.collaborations.size).to eq 0
            end
            specify 'group is no longer a collaborator' do
              subject
              expect(owner.is_collaborator_of?(project)).to eq false
            end
          end

          context 'raising error by an unexisted user' do
            let(:params) { { owner_name: project.owner, id: project, new_owner_name: 'unexisted_user_slug' } }
            let(:xhr) { true }

            it do
              aggregate_failures do
                is_expected.to have_http_status(400)
                expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
              end
            end
          end
        end

        context 'for normal update' do
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
