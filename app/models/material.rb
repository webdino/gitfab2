class Material < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :status
end
