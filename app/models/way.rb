class Way < ActiveRecord::Base
  belongs_to :prev_status, class_name: Status.name
  belongs_to :next_status, class_name: Status.name
  has_many :tools
end
