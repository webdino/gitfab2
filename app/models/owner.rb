class Owner < ActiveRecord::Base
  has_many :recipes
  has_one :namespace
end
