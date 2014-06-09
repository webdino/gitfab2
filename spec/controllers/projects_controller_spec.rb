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
          before{get :index, owner_name: project.owner.name}
          it{should render_template :index}
        end
        context "with queries" do
          before{get :index, owner_name: project.owner.name, q: "foo"}
          it{should render_template :index}
        end
      end
      describe "GET new" do
        before{get :new, owner_name: project.owner.name, id: project.id}
        it{should render_template :new}
      end
      describe "GET edit" do
        before{get :edit, owner_name: project.owner.name, id: project.id}
        it{should render_template :edit}
      end
      describe "POST create" do
        context "when newly creating" do
          let(:user){FactoryGirl.create :user}
          let(:new_project){FactoryGirl.build(:user_project)}
          before do
            post :create, owner_name: user.name, project: new_project.attributes
          end
          it{should redirect_to project_path(id: new_project.name, owner_name: user.name)}
        end
        context "when forking" do
          let(:forker){FactoryGirl.create :user}
          before do
            post :create, owner_name: forker.name, original_project_id: user_project.id
          end
          it{should redirect_to project_path(id: user_project.name, owner_name: forker.name)}
        end
      end
    end
  end
end
