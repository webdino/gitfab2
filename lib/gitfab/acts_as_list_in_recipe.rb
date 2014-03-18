module Gitfab::ActsAsListInRecipe
  extend ActiveSupport::Concern
  module ClassMethods
    def acts_as_list_in_recipe
      self.acts_as_list scope: :recipe
      self.scope :sorted_by_position, ->{order :position}
    end
  end
end
