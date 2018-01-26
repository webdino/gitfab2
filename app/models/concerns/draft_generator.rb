module DraftGenerator
  extend ActiveSupport::Concern

  def generate_draft
    raise NotImplementedError
  end
end
