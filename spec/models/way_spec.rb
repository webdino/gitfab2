require "spec_helper"

describe Way do
  disconnect_sunspot
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:status){FactoryGirl.create :status, recipe: recipe}
  let(:way){FactoryGirl.create :way, status: status}

  describe "on after_update" do
    describe "clears video_id field when a photo was uploaded" do
      let(:way_having_video_id) do
        FactoryGirl.create :way, recipe: recipe, video_id: "foo",
          photo: nil, status: status
      end
      before do
        way_having_video_id
          .update_attributes photo: UploadFileHelper.upload_file
      end
      subject{way_having_video_id.video_id.blank?}
      it{should be_true}
    end

    describe "clears photo field when video_id was uploaded" do
      let(:way_having_photo) do
        FactoryGirl.create :way, recipe: recipe,
          video_id: nil, photo: UploadFileHelper.upload_file,
          status: status
      end
      before do
        way_having_photo.update_attributes video_id: "foo"
      end
      subject{way_having_photo.photo.blank?}
      it{should be_true}
    end
  end
end
