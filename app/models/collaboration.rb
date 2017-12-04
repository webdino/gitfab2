class Collaboration < ActiveRecord::Base
  belongs_to :owner, polymorphic: true, required: true
  belongs_to :project, required: true
end
