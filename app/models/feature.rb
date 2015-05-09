class Feature
  TARGET_CLASS = {Project: "Project", Group: "Group", User: "User" }

  include Mongoid::Document
  include Mongoid::Timestamps

  scope :projects, ->{where class_name: "Project"}
  scope :groups, ->{where class_name: "Group"}
  scope :users, ->{where class_name: "User"}

  has_many :featured_items
  accepts_nested_attributes_for :featured_items

  field :name
  field :class_name
  field :category, type: Fixnum, default: 0

  class << self
    def updatable_columns
      [:name, :class_name, :category]
    end
  end
end
