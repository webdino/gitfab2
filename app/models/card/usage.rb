class Card::Usage < Card
  include Mongoid::Orderable
  embedded_in :project
  orderable column: :position
  class << self
    def updatable_columns
      super + [:position]
    end
  end
end
