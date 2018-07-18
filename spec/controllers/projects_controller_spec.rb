# frozen_string_literal: true

describe ProjectsController, type: :controller do
  render_views

  subject { response }

  let(:user_project) { FactoryBot.create :user_project }
  let(:group_project) { FactoryBot.create :group_project }

  %w[user group].each do |owner_type|
    let(:project) { send "#{owner_type}_project" }
    context "with a project owned by a #{owner_type}" do
      describe 'GET index' do
        context 'with owner name' do
          before { get :index, params: { owner_name: project.owner.slug } }
          it { is_expected.to render_template :index }
        end
        context 'with owner id' do
          before { get :index, params: { "#{owner_type}_id": project.owner.slug } }
          it { is_expected.to render_template :index }
        end
      end
      describe 'GET show' do
        before do
          get :show, params: { owner_name: project.owner.slug, id: project.name }
        end
        it { is_expected.to render_template 'recipes/show' }
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
          it { is_expected.to redirect_to projects_path(owner_name: project.owner.slug) }
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
          it { is_expected.to redirect_to projects_path(owner_name: project.owner.slug) }
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
            post :create, params: { user_id: user.slug, project: new_project.attributes }
          end
          it { is_expected.to redirect_to(edit_project_url(id: assigns(:project), owner_name: user)) }
        end
        context 'when newly creating with wrong parameters' do
          let(:user) { FactoryBot.create :user }
          let(:new_project) { FactoryBot.build(:user_project, original: nil) }
          before do
            sign_in user
            wrong_parameters = new_project.attributes
            wrong_parameters['title'] = ''
            post :create, params: { user_id: user.slug, project: wrong_parameters }
          end
          it { is_expected.to render_template :new }
        end
        context 'when forking' do
          let(:forker) { FactoryBot.create :user }
          before do
            sign_in forker
            user_project.recipe.states.create type: 'Card::State', title: 'sta1', description: 'desc1'
            user_project.recipe.states.first.annotations.create title: 'ann1', description: 'anndesc1'
            user_project.reload
            post :create, params: { user_id: forker.slug, original_project_id: user_project.id }
          end
          it { is_expected.to redirect_to project_path(id: Project.last.name, owner_name: forker.slug) }
          it 'has 1 states and 1 annotation' do
            aggregate_failures do
              recipe_states = Project.last.recipe.states
              expect(recipe_states.size).to eq 1
              expect(recipe_states.first.annotations.size).to eq 1
            end
          end
        end
        context 'when forking with a wrong parameter' do
          let(:forker) { FactoryBot.create :user }
          let!(:original_project) { FactoryBot.create :user_project }

          before do
            sign_in forker
            original_project.recipe.states.create type: 'Card::State', title: 'sta1', description: 'desc1'
            original_project.recipe.states.first.annotations.create title: 'ann1', description: 'anndesc1'
            original_project.reload
            post :create, params: { user_id: forker.slug, original_project_id: 'wrongparameter' }
          end
          it { is_expected.to have_http_status(404) }
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
        context 'transfering project ownership by #change_owner' do
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
          end
          context 'to user' do
            let!(:user) { FactoryBot.create(:user) }
            before do
              user.collaborations.create project_id: project.id
              if owner_type == 'user'
                patch :update, params: { user_id: project.owner, id: project, new_owner_name: user }
              else
                patch :update, params: { group_id: project.owner, id: project, new_owner_name: user }
              end
              user.reload
            end
            it { is_expected.to redirect_to projects_path(owner_name: user) }
            it 'has 0 collaborations' do
              expect(user.collaborations.size).to eq 0
            end
            specify 'group is no longer a collaborator' do
              expect(user.is_collaborator_of?(project)).to eq false
            end
          end
          context 'to group' do
            let!(:group) { FactoryBot.create :group }
            before do
              group.collaborations.create project_id: project.id
              if owner_type == 'user'
                patch :update, params: { user_id: project.owner, id: project, new_owner_name: group }
              else
                patch :update, params: { group_id: project.owner, id: project, new_owner_name: group }
              end
              group.reload
            end
            it { is_expected.to redirect_to projects_path(owner_name: group) }
            it 'has 0 collaborations' do
              expect(group.collaborations.size).to eq 0
            end
            specify 'group is no longer a collaborator' do
              expect(group.is_collaborator_of?(project)).to eq false
            end
          end
          context 'raising error by an unexisted user' do
            before do
              if owner_type == 'User'
                patch :update,
                  params: { user_id: project.owner.slug, id: project.id, new_owner_name: 'unexisted_user_slug' },
                  xhr: true
              else
                patch :update,
                  params: { group_id: project.owner.slug, id: project.id, new_owner_name: 'unexisted_user_slug' },
                  xhr: true
              end
            end
            it do
              aggregate_failures do
                is_expected.to have_http_status(400)
                expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
              end
            end
          end
        end

        context 'for normal update' do
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
          end
          context 'success' do
            before do
              if owner_type == 'user'
                patch :update, params: { user_id: project.owner.slug, id: project.id, project: { description: '_proj' } }
              else
                patch :update, params: { group_id: project.owner.slug, id: project.id, project: { description: '_proj' } }
              end
            end
            it { is_expected.to redirect_to project_path(owner_name: project.owner.slug, id: project) }
          end
          context 'raising error by invalid title' do
            before do
              if owner_type == 'user'
                patch :update, params: { user_id: project.owner.slug, id: project.id, project: { title: '' } }
              else
                patch :update, params: { group_id: project.owner.slug, id: project.id, project: { title: '' } }
              end
            end
            it { is_expected.to render_template :edit }
          end
        end
      end
    end
  end
end
