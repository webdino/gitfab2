class Tag < ActiveRecord::Base
  include MongoidStubbable
  include Contributable
  belongs_to :user

  belongs_to :taggable, polymorphic: true

  class << self
    def updatable_columns
      [:_destroy, :name, :user_id]
    end
  end
end
