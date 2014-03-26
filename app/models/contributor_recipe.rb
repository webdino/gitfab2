class ContributorRecipe < ActiveRecord::Base
  belongs_to :contributor, class_name: User.name
  belongs_to :recipe
end
