class ContributorRecipe < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :contributor, class_name: User.name
  belongs_to :recipe
end
