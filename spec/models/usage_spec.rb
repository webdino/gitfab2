require "spec_helper"

describe Usage do
  disconnect_sunspot
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:usage){FactoryGirl.create :usage, recipe: recipe}

  describe "on after_update" do
    describe "clears video_id field when a photo was uploaded" do
      let(:usage_having_video_id) do
        FactoryGirl.create :usage, recipe: recipe, video_id: "foo", photo: nil
      end
      before do
        usage_having_video_id
          .update_attributes photo: UploadFileHelper.upload_file
      end
      subject{usage_having_video_id.video_id.blank?}
      it{should be_true}
    end

    describe "clears photo field when video_id was uploaded" do
      let(:usage_having_photo) do
        FactoryGirl.create :usage, recipe: recipe,
          video_id: nil, photo: UploadFileHelper.upload_file
      end
      before do
        usage_having_photo.update_attributes video_id: "foo"
      end
      subject{usage_having_photo.photo.blank?}
      it{should be_true}
    end
  end
end
