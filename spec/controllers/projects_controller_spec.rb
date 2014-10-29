require "spec_helper"

describe ProjectsController, type: :controller do
  disconnect_sunspot
  render_views

  subject{response}

  let(:user_project){FactoryGirl.create :user_project}
  let(:group_project){FactoryGirl.create :group_project}

  %w(user group).each do |owner_type|
    let(:project){send "#{owner_type}_project"}
    context "with a project owned by a #{owner_type}" do
      describe "GET index" do
        context "with no query" do
          before{get :index, owner_name: project.owner.slug}
          it{should render_template :index}
        end
        context "with queries" do
          before{get :index, owner_name: project.owner.slug, q: "foo"}
          it{should render_template :index}
        end
      end
      describe "GET new" do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :new, owner_name: project.owner.slug, id: project.id
        end
        it{should render_template :new}
      end
      describe "GET edit" do
        before do
          user_project.owner.memberships.create group_id: group_project.owner.id
          sign_in user_project.owner
          get :edit, owner_name: project.owner.slug, id: project.id
        end
        #before{get :edit, owner_name: project.owner.slug, id: project.id}
        it{should render_template :edit}
      end
      describe "POST create" do
        context "when newly creating" do
          let(:user){FactoryGirl.create :user}
          let(:new_project){FactoryGirl.build(:user_project, original: nil)}
          before do
            sign_in user
            post :create, user_id: user.slug, project: new_project.attributes
          end
          it{should render_template :edit}
        end
        context "when forking" do
          let(:forker){FactoryGirl.create :user}
          before do
            sign_in forker
            user_project.recipe.states.create _type: "Card::State", title: "sta1", description: "desc1"
            user_project.recipe.states.first.annotations.create title: "ann1", description: "anndesc1"
            user_project.reload
            post :create, user_id: forker.slug, original_project_id: user_project.id
          end
          it{should redirect_to project_path(id: Project.last.name, owner_name: forker.slug)}
          it{expect(Project.last.recipe).to have(1).state}
          it{expect(Project.last.recipe.states.first).to have(1).annotation}
        end
      end
    end
  end
end
