class Contribution < ActiveRecord::Base
  belongs_to :contributor, class_name: 'User', required: true
  belongs_to :contributable, polymorphic: true
end
