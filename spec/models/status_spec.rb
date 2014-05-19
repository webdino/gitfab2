require "spec_helper"

describe Status do
  disconnect_sunspot
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:status){FactoryGirl.create :status, recipe: recipe}

  describe "on after_update" do
    describe "clears video_id field when a photo was uploaded" do
      let(:status_having_video_id) do
        FactoryGirl.create :status, recipe: recipe, video_id: "foo", photo: nil
      end
      before do
        status_having_video_id
          .update_attributes photo: UploadFileHelper.upload_file
      end
      subject{status_having_video_id.video_id.blank?}
      it{should be_true}
      it{status_having_video_id.photo.present?.should be_true}
    end

    describe "clears photo field when video_id was uploaded" do
      let(:status_having_photo) do
        FactoryGirl.create :status, recipe: recipe,
          video_id: nil, photo: UploadFileHelper.upload_file
      end
      before do
        status_having_photo.update_attributes video_id: "foo"
      end
      subject{status_having_photo.photo.blank?}
      it{should be_true}
      it{status_having_photo.video_id.present?.should be_true}
    end
  end
end
