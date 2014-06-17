module Forkable
  extend ActiveSupport::Concern
  included do
    embeds_many :derivatives, class_name: name, inverse_of: :original
    embedded_in :original, class_name: name, inverse_of: :derivative

    accepts_nested_attributes_for :derivatives

    def replace_with_a_derivative derivative
      unless self.derivatives.include? derivative
        raise "#{derivative.class} was given. The argument _derivative_ must be embedded as a derivative."
      end
      derivative.dup.tap do |new_parent|
        to_move = self.derivatives.reject{|d| d == derivative}
        to_move.unshift self.class.new(self.attributes.reject{|k, v| k == :derivatives})
        new_parent.derivatives = to_move
      end
    end
  end
end
