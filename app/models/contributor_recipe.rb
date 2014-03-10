class ContributorRecipe < ActiveRecord::Base
  belongs_to :contributors, class_name: User.name
  belongs_to :recipe
end
