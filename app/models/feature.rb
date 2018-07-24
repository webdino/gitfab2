# == Schema Information
#
# Table name: features
#
#  id         :integer          not null, primary key
#  category   :integer          default(0), not null
#  class_name :string(255)
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Feature < ApplicationRecord
  TARGET_CLASS = { Project: 'Project', Group: 'Group', User: 'User' }

  scope :projects, -> { where class_name: 'Project' }
  scope :groups, -> { where class_name: 'Group' }
  scope :users, -> { where class_name: 'User' }

  has_many :featured_items, dependent: :destroy
  accepts_nested_attributes_for :featured_items

  class << self
    def updatable_columns
      [:name, :class_name, :category]
    end
  end
end
