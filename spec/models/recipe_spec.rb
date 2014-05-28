require "spec_helper"

describe Recipe do
  disconnect_sunspot
  let(:u_project){FactoryGirl.create :user_project}
  let(:u_project_recipe){u_project.recipe}
  let(:g_project){FactoryGirl.create :group_project}
  let(:g_project_recipe){g_project.recipe}

  describe "#dup_document" do
    context "with a user recipe" do
      it{expect(u_project_recipe.dup_document).to be_a Recipe}
    end
    context "with a group recipe" do
      it{expect(g_project_recipe.dup_document).to be_a Recipe}
    end
  end
end
