module Gitfab::ActsAsItemInRecipe
  extend ActiveSupport::Concern
  included do
    acts_as_list scope: :recipe
    acts_as_votable

    scope :sorted_by_position, ->{order :position}
    mount_uploader :photo, ItemPhotoUploader

    belongs_to :recipe

    before_create ->{self.filename = "#{SecureRandom.uuid}.json" unless self.filename}

    def to_path
      File.join dir_path, self.filename
    end

    def photo_path
      File.join dir_path, "photos", self.photo.file.filename
    end

    def dir_path
      self.class.name.underscore.pluralize
    end

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
