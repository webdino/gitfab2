class Owner < ActiveRecord::Base
  has_many :recipes
end
