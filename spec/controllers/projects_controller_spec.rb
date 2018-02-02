require 'spec_helper'

describe ProjectsController, type: :controller do
  render_views

  subject{response}

  let(:user_project){FactoryGirl.create :user_project}
  let(:group_project){FactoryGirl.create :group_project}

  %w(user group).each do |owner_type|
    let(:project){send "#{owner_type}_project"}
    context "with a project owned by a #{owner_type}" do
      describe 'GET index' do
        context 'with owner name' do
          before{get :index, owner_name: project.owner.slug}
          it{ is_expected.to render_template :index }
        end
        context 'with owner id' do
          before{ get :index, "#{owner_type}_id": project.owner.slug }
          it { is_expected.to render_template :index }
        end
      end
      describe 'GET show' do
        before do
          get :show, owner_name: project.owner.slug, id: project.name
        end
        it{ is_expected.to render_template 'recipes/show' }
      end
      describe 'GET new' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :new, owner_name: project.owner.slug, id: project.id
        end
        it{ is_expected.to render_template :new }
      end
      describe 'DELETE destroy' do
        context 'without collaborators' do
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
            delete :destroy, owner_name: project.owner.slug, id: project.id
          end
          it{ is_expected.to redirect_to projects_path(owner_name: project.owner.slug)}
        end
        context 'with collaborators' do
          let(:user){FactoryGirl.create :user}
          let(:group){FactoryGirl.create :group}
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
            user.collaborations.create project_id: project
            group.collaborations.create project_id: project
            delete :destroy, owner_name: project.owner.slug, id: project.id
            user.reload
            group.reload
          end
          it{ is_expected.to redirect_to projects_path(owner_name: project.owner.slug)}
          it{ expect(user).to have(0).collaboration}
          it{ expect(group).to have(0).collaboration}
        end
      end
      describe 'GET edit' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :edit, owner_name: project.owner.slug, id: project.id
        end
        it{ is_expected.to render_template :edit }
      end
      describe 'POST create' do
        context 'when newly creating' do
          let(:user){FactoryGirl.create :user}
          let(:new_project){FactoryGirl.build(:user_project, original: nil)}
          before do
            sign_in user
            post :create, user_id: user.slug, project: new_project.attributes
          end
          it{ is_expected.to redirect_to(edit_project_url(id: assigns(:project), owner_name: user)) }
        end
        context 'when newly creating with wrong parameters' do
          let(:user){FactoryGirl.create :user}
          let(:new_project){FactoryGirl.build(:user_project, original: nil)}
          before do
            sign_in user
            wrong_parameters = new_project.attributes
            wrong_parameters['title'] = ''
            post :create, user_id: user.slug, project: wrong_parameters
          end
          it{ is_expected.to render_template :new}
        end
        context 'when forking' do
          let(:forker){FactoryGirl.create :user}
          before do
            sign_in forker
            user_project.recipe.states.create type: 'Card::State', title: 'sta1', description: 'desc1'
            user_project.recipe.states.first.annotations.create title: 'ann1', description: 'anndesc1'
            user_project.reload
            post :create, user_id: forker.slug, original_project_id: user_project.id
          end
          it{ is_expected.to redirect_to project_path(id: Project.last.name, owner_name: forker.slug) }
          it{expect(Project.last.recipe).to have(1).state}
          it{expect(Project.last.recipe.states.first).to have(1).annotation}
        end
        context 'when forking with a wrong parameter' do
          let(:forker){FactoryGirl.create :user}
          let!(:original_project) { FactoryGirl.create :user_project }

          before do
            sign_in forker
            original_project.recipe.states.create type: 'Card::State', title: 'sta1', description: 'desc1'
            original_project.recipe.states.first.annotations.create title: 'ann1', description: 'anndesc1'
            original_project.reload
            post :create, user_id: forker.slug, original_project_id: 'wrongparameter'
          end
          it { is_expected.to have_http_status(404) }
        end
      end
      describe 'GET potential_owners' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          if owner_type == 'user'
            xhr :get, :potential_owners, user_id: project.owner.slug, project_id: project.slug
          else
            xhr :get, :potential_owners, group_id: project.owner.slug, project_id: project.slug
          end
        end
        it { is_expected.to render_template 'potential_owners' }
      end
      describe 'GET recipe_cards_list' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner
          sign_in user_project.owner
          if owner_type == 'user'
            xhr :get, :recipe_cards_list, user_id: project.owner, project_id: project
          else
            xhr :get, :recipe_cards_list, group_id: project.owner, project_id: project
          end
        end
        it{ is_expected.to render_template 'recipe_cards_list' }
      end

      describe 'PATCH update' do
        context 'for likes attributes' do
          let(:user){FactoryGirl.create :user}
          before do
            sign_in user
          end

          let(:patch_to_success) do
            if owner_type == 'user'
              xhr :patch, :update, user_id: project.owner, id: project, project: {likes_attributes: {'1341431431' => {liker_id: user.id, _destroy: false}}}
            else
              xhr :patch, :update, group_id: project.owner, id: project, project: {likes_attributes: {'1341431431' => {liker_id: user.id, _destroy: false}}}
            end
          end

          let(:patch_to_fail) do
            if owner_type == 'user'
              xhr :patch, :update, user_id: project.owner, id: project, project: {title: '', likes_attributes: {'1341431431' => {liker_id: 'invalid', _destroy: false}}}
            else
              xhr :patch, :update, group_id: project.owner, id: project, project: {title: '', likes_attributes: {'1341431431' => {liker_id: 'invalid', _destroy: false}}}
            end
          end

          context 'success' do
            before { patch_to_success }
            it { is_expected.to redirect_to [project, owner_name: project.owner] }
          end
          context 'fail' do
            before { patch_to_fail }
            it { is_expected.to have_http_status(400) }
            it { is_expected.to render_template :edit }
          end
          context 'for timestamps' do
            it 'should not change updated_at on success' do
              travel 1.day do
                expect { patch_to_success }.not_to change { project.reload.updated_at }
              end
            end
            it 'should not change updated_at on fail' do
              travel 1.day do
                expect { patch_to_fail }.not_to change { project.reload.updated_at }
              end
            end
          end
        end

        context 'transfering project ownership by #change_owner' do
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
          end
          context 'to user' do
            let!(:user) { FactoryGirl.create(:user) }
            before do
              user.collaborations.create project_id: project.id
              if owner_type == 'user'
                patch :update, user_id: project.owner, id: project, new_owner_name: user
              else
                patch :update, group_id: project.owner, id: project, new_owner_name: user
              end
              user.reload
            end
            it{ is_expected.to redirect_to projects_path(owner_name: user)}
            it 'has 0 collaborations' do
              expect(user.collaborations.size).to eq 0
            end
            specify 'group is no longer a collaborator' do
              expect(user.is_collaborator_of?(project)).to eq false
            end
          end
          context 'to group' do
            let!(:group){FactoryGirl.create :group}
            before do
              group.collaborations.create project_id: project.id
              if owner_type == 'user'
                patch :update, user_id: project.owner, id: project, new_owner_name: group
              else
                patch :update, group_id: project.owner, id: project, new_owner_name: group
              end
              group.reload
            end
            it{ is_expected.to redirect_to projects_path(owner_name: group) }
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
                xhr :patch, :update, user_id: project.owner.slug, id: project.id, new_owner_name: 'unexisted_user_slug'
              else
                xhr :patch, :update, group_id: project.owner.slug, id: project.id, new_owner_name: 'unexisted_user_slug'
              end
            end
            it "should renders 'errors/failed' with 400" do
              aggregate_failures do
                is_expected.to render_template 'errors/failed'
                is_expected.to have_http_status(400)
                json = JSON.parse(subject.body)
                expect(json['success']).to eq false
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
                patch :update, user_id: project.owner.slug, id: project.id, project: {description: '_proj'}
              else
                patch :update, group_id: project.owner.slug, id: project.id, project: {description: '_proj'}
              end
            end
            it{ is_expected.to redirect_to project_path(owner_name: project.owner.slug, id: project)}
          end
          context 'raising error by invalid title' do
            before do
              if owner_type == 'user'
                patch :update, user_id: project.owner.slug, id: project.id, project: {title: ''}
              else
                patch :update, group_id: project.owner.slug, id: project.id, project: {title: ''}
              end
            end
            it { is_expected.to render_template :edit }
          end
        end
      end
    end
  end
end
