class Tool < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :way
end
