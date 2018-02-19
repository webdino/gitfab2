class Contribution < ActiveRecord::Base
  belongs_to :contributor, class_name: 'User', required: true
  # TODO: required: true を付けられるかどうか要検討
  belongs_to :contributable, polymorphic: true
end
