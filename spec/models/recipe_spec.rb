require "spec_helper"

describe Recipe do
  disconnect_sunspot

  let(:recipe){FactoryGirl.create :user_recipe}
  let(:g_recipe){FactoryGirl.create :group_recipe}
  let(:status){FactoryGirl.create :status, recipe: recipe}
  let(:way){FactoryGirl.create :way, status: status}
  let(:tool){FactoryGirl.create :tool, recipe: recipe}
  let(:material){FactoryGirl.create :material, recipe: recipe}

  describe "#save" do
    describe "persists owner-scoped unique slug" do
      let(:user1){FactoryGirl.create :user}
      let(:user2){FactoryGirl.create :user}
      let(:group1){FactoryGirl.create :group}
      let(:new_recipe1){FactoryGirl.create :user_recipe, name: "new_recipe", owner: user1}
      let(:new_recipe2){FactoryGirl.create :user_recipe, name: "new_recipe", owner: user2}
      let(:new_g_recipe){FactoryGirl.create :group_recipe, name: "new_recipe", owner: group1}
      let(:slugs){[new_recipe1, new_recipe2, new_g_recipe].map(&:slug)}
      subject do
        slugs.all?{|slug| slug == "new_recipe"}
      end
      it{should be_true}
    end
  end

  describe "#owner" do
    context "when owned by a user" do
      subject{recipe.owner}
      it{should be_a User}
    end
    context "when owned by a group" do
      subject{g_recipe.owner}
      it{should be_a Group}
    end
  end

  describe "#fork_for!" do
    let(:other){FactoryGirl.create :user}
    let(:forked_recipe){recipe.fork_for! other}
    let(:forked_recipe2){recipe.fork_for! other}
    before do
      status; way; tool; material
    end

    context "when the recipe has items which don't have photo" do
      before do
        status = recipe.statuses.create
        status.ways.create
        recipe.tools.create
        recipe.materials.create
      end
      subject{recipe.fork_for! other}
      it{should be_a Recipe}
    end

    describe "copies the photo file which the original recipe has" do
      subject{forked_recipe.photo.present?}
      it{should be_true}
    end

    describe "copies the photo file which the items belong to the original recipe has" do
      subject do
        forked_recipe.statuses.all?{|status| status.photo.present?} &&
          forked_recipe.ways.all?{|way| way.photo.present?} &&
          forked_recipe.tools.all?{|tool| tool.photo.present?} &&
          forked_recipe.materials.all?{|material| material.photo.present?}
      end
      it{should be_true}
    end
  end

  describe "on before_update" do
    describe "clear_video_id_or_photo_if_needed" do
      context "when video_id is set" do
        before do
          recipe.update_attributes video_id: "foo"
        end
        subject{recipe.photo.present?}
        it{should be_false}
      end
      context "when photo is set" do
        let(:recipe_with_video_id){FactoryGirl.create :recipe, video_id: "foo"}
        before do
          recipe.update_attributes photo: UploadFileHelper.upload_file
        end
        subject{recipe.photo.present?}
        it{should be_true}
      end
    end
  end

  describe "on after_update" do
    describe "clears video_id field when a photo was uploaded" do
      let(:recipe_having_video_id) do
        FactoryGirl.create :user_recipe, video_id: "foo", photo: nil
      end
      before do
        recipe_having_video_id
          .update_attributes photo: UploadFileHelper.upload_file
      end
      subject{recipe_having_video_id.video_id.blank?}
      it{should be_true}
    end

    describe "clears photo field when video_id was uploaded" do
      let(:recipe_having_photo) do
        FactoryGirl.create :user_recipe,
          video_id: nil, photo: UploadFileHelper.upload_file
      end
      before do
        recipe_having_photo.update_attributes video_id: "foo"
      end
      subject{recipe_having_photo.photo.blank?}
      it{should be_true}
    end

  end

  describe "ensure the statuses are terminated with a Status which has no Way" do
    context "when the last status which doesn't have Way" do
      before do
        status1 = recipe.statuses.create
        status1.ways.create
        recipe.statuses.create
        recipe.run_callbacks :commit
      end
      subject{recipe.statuses.sorted_by_position.last}
      it{should have(0).ways}
    end
    context "when the last status which has Way" do
      before do
        status1 = recipe.statuses.create
        status1.ways.create
        status2 = recipe.statuses.create
        status2.ways.create
        recipe.run_callbacks :commit
      end
      subject{recipe.statuses.sorted_by_position.last}
      it{should have(0).ways}
    end
  end

  describe "can have tags" do
    before do
      recipe.tag_list = ["foo", "bar"]
      recipe.save
    end
    subject{recipe.reload}
    its(:tags){should have(2).items}
  end
end
