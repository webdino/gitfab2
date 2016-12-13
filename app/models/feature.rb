class Feature < ActiveRecord::Base
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
