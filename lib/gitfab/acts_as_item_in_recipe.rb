module Gitfab::ActsAsItemInRecipe
  extend ActiveSupport::Concern
  included do
    acts_as_list scope: :recipe
    acts_as_votable

    scope :sorted_by_position, ->{order :position}
    mount_uploader :photo, ItemPhotoUploader

    belongs_to :recipe

    before_create ->{self.filename = "#{SecureRandom.uuid}.json" unless self.filename}

    def dup_with_photo
      self.dup.tap{|item| item.photo = dup_photo if self.photo.present?}
    end

    private
    def dup_photo
      ActionDispatch::Http::UploadedFile.new filename: self.photo.file.filename,
        type: self.photo.file.content_type, tempfile: File.open(self.photo.path)
    end
  end
end
