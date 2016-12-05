class Card::Usage < Card
  belongs_to :project
  acts_as_list scope: :recipe
  class << self
    def updatable_columns
      super + [:position]
    end
  end
end
