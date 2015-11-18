class Right
  include Mongoid::Document
  belongs_to :project
  belongs_to :right_holder, polymorphic: true
end
