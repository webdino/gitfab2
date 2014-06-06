module Figurable
  extend ActiveSupport::Concern
  included do
    embeds_many :figures, cascade_callbacks: true do
      Figure.subclasses.each do |klass|
        define_method klass.model_name.element.pluralize do
          where _type: klass.name
        end
      end
    end
    accepts_nested_attributes_for :figures
  end
end
