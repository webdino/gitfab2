require 'spec_helper'

describe ProjectsController, type: :controller do
  disconnect_sunspot
  render_views

  subject{response}

  let(:user_project){FactoryGirl.create :user_project}
  let(:group_project){FactoryGirl.create :group_project}

  %w(user group).each do |owner_type|
    let(:project){send "#{owner_type}_project"}
    context "with a project owned by a #{owner_type}" do
      describe 'GET index' do
        context 'with no query' do
          before{get :index, owner_name: project.owner.slug}
          it{should render_template :index}
        end
        context 'with single querie' do
          before{get :index, owner_name: project.owner.slug, q: 'foo'}
          it{should render_template :index}
        end
        context 'with multi queries' do
          before{get :index, owner_name: project.owner.slug, q: 'foo bar'}
          it{expect render_template :index}
        end
      end
      describe 'GET show' do
        before do
        get :show, owner_name: project.owner.slug, id: project.name
        end
        it{expect render_template 'recipes/show'}
      end
      describe 'GET new' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :new, owner_name: project.owner.slug, id: project.id
        end
        it{should render_template :new}
      end
      describe 'DELETE destroy' do
        context 'without collaborators' do
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
            delete :destroy, owner_name: project.owner.id, id: project.id
          end
          it{expect redirect_to projects_path(owner_name: project.owner.slug)}
        end
        context 'with collaborators' do
          let(:user){FactoryGirl.create :user}
          let(:group){FactoryGirl.create :group}
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
            user.collaborations.create project_id: project
            group.collaborations.create project_id: project
            delete :destroy, owner_name: project.owner.id, id: project.id
            user.reload
            group.reload
          end
          it{expect redirect_to projects_path(owner_name: project.owner.slug)}
          it{expect(user).to have(0).collaboration}
          it{expect(group).to have(0).collaboration}
          it{expect(Project.where(right_holder_id: user.id).length).to eq(0)}
          it{expect(Project.where(right_holder_id: group.id).length).to eq(0)}
        end
      end
      describe 'GET edit' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :edit, owner_name: project.owner.slug, id: project.id
        end
        it{should render_template :edit}
      end
      describe 'POST create' do
        context 'when newly creating' do
          let(:user){FactoryGirl.create :user}
          let(:new_project){FactoryGirl.build(:user_project, original: nil)}
          before do
            sign_in user
            post :create, user_id: user.slug, project: new_project.attributes
          end
          it{should render_template :edit}
          it{expect(Project.last.rights).to have(1).right}
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
          it{expect render_template :new}
        end
        context 'when forking' do
          let(:forker){FactoryGirl.create :user}
          before do
            sign_in forker
            user_project.recipe.states.create _type: 'Card::State', title: 'sta1', description: 'desc1'
            user_project.recipe.states.first.annotations.create title: 'ann1', description: 'anndesc1'
            user_project.reload
            post :create, user_id: forker.slug, original_project_id: user_project.id
          end
          it{should redirect_to project_path(id: Project.last.name, owner_name: forker.slug)}
          it{expect(Project.last.recipe).to have(1).state}
          it{expect(Project.last.recipe.states.first).to have(1).annotation}
        end
        context 'when forking with a wrong parameter' do
          let(:forker){FactoryGirl.create :user}
          before do
            sign_in forker
            user_project.recipe.states.create _type: 'Card::State', title: 'sta1', description: 'desc1'
            user_project.recipe.states.first.annotations.create title: 'ann1', description: 'anndesc1'
            user_project.reload
            post :create, user_id: forker.slug, original_project_id: 'wrongparameter'
          end
          it{expect redirect_to project_path(owner_name: user_project.owner.slug, id: user_project.name)}
        end
      end
      describe 'GET potential_owners' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          if owner_type == 'user'
            xhr :get, :potential_owners, user_id: project.owner.id, project_id: project.id
          else
            xhr :get, :potential_owners, group_id: project.owner.id, project_id: project.id
          end
        end
        it{expect render_template 'potential_owners'}
      end
      describe 'GET recipe_cards_list' do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          if owner_type == 'user'
            xhr :get, :recipe_cards_list, user_id: project.owner.id, project_id: project.id
          else
            xhr :get, :recipe_cards_list, group_id: project.owner.id, project_id: project.id
          end
        end
        it{expect render_template 'recipe_cards_list'}
      end

      describe 'PATCH update' do
        context 'for likes attributes' do
          let(:user){FactoryGirl.create :user}
          before do
            sign_in user
          end
          context 'success' do
            before do
              if owner_type == 'user'
                xhr :patch, :update, user_id: project.owner.id, id: project.id, project: {likes_attributes: {'1341431431' => {liker_id: user.slug, _destroy: false}}}
              else
                xhr :patch, :update, group_id: project.owner.id, id: project.id, project: {likes_attributes: {'1341431431' => {liker_id: user.slug, _destroy: false}}}
              end
            end
            it{expect render_template :update}
          end
          context 'error' do
            before do
              if owner_type == 'user'
                xhr :patch, :update, user_id: project.owner.id, id: project.id, project: {title: '', likes_attributes: {'1341431431' => {liker_id: user.slug, _destroy: false}}, unexisted_attr: 'unexisted attribute'}
              else
                xhr :patch, :update, group_id: project.owner.id, id: project.id, project: {title: '', likes_attributes: {'1341431431' => {liker_id: user.slug, _destroy: false}}, unexisted_attr: 'unexisted attribute'}
              end
            end
            it{expect render_template 'error/failed'}
          end
        end

        context 'transfering project ownership by #change_owner' do
          let(:user){FactoryGirl.create :user}
          let(:group){FactoryGirl.create :group}
          before do
            user_project.owner.memberships.create group_id: group_project.owner.id
            sign_in user_project.owner
          end
          context 'to user' do
            before do
              user.collaborations.create project_id: project
              if owner_type == 'user'
                patch :update, user_id: project.owner.id, id: project.id, new_owner_name: user.slug
              else
                patch :update, group_id: project.owner.id, id: project.id, new_owner_name: user.slug
              end
              user.reload
            end
            it{expect redirect_to project_path(owner_name: user.slug, id: project.id)}
            it{expect(user).to have(0).collaboration}
          end
          context 'to group' do
            before do
              group.collaborations.create project_id: project
              if owner_type == 'user'
                patch :update, user_id: project.owner.id, id: project.id, new_owner_name: group.slug
              else
                patch :update, group_id: project.owner.id, id: project.id, new_owner_name: group.slug
              end
              group.reload
            end
            it{expect redirect_to project_path(owner_name: group.slug, id: project.id)}
            it{expect(group).to have(0).collaboration}
          end
          context 'raising error by an unexisted user' do
            before do
              if owner_type == 'user'
                patch :update, user_id: project.owner.id, id: project.id, new_owner_name: 'unexisted_user_slug'
              else
                patch :update, group_id: project.owner.id, id: project.id, new_owner_name: 'unexisted_user_slug'
              end
            end
            it{expect render_template 'error/failed', status: 400}
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
                patch :update, user_id: project.owner.id, id: project.id, project: {description: '_proj'}
              else
                patch :update, group_id: project.owner.id, id: project.id, project: {description: '_proj'}
              end
            end
            it{expect redirect_to project_path(owner_name: project.owner.slug, id: project.id)}
          end
          context 'raising error by invalid title' do
            before do
              if owner_type == 'user'
                patch :update, user_id: project.owner.id, id: project.id, project: {title: ''}
              else
                patch :update, group_id: project.owner.id, id: project.id, project: {title: ''}
              end
            end
            it{expect redirect_to edit_project_path(owner_name: project.owner.slug, id: project.id)}
          end
        end
      end
    end
  end
end
