module Gitfab::ActsAsItemInRecipe
  extend ActiveSupport::Concern
  included do
    acts_as_list scope: :recipe
    scope :sorted_by_position, ->{order :position}
    mount_uploader :photo, PhotoUploader

    belongs_to :recipe

    before_create ->{self.filename = "#{SecureRandom.uuid}.json" unless self.filename}

    def to_path
      repo_path = self.recipe.repo.path
      dir_name  = self.class.name.underscore.pluralize
      File.join dir_name, self.filename
    end
  end
end
