require "spec_helper"

describe Card::State do
  let(:state){FactoryGirl.build :state}

  describe "#is_taggable?" do
    subject{state.is_taggable?}
    it{should be false}
  end
end
