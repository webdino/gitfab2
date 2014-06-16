require "spec_helper"

describe Card::Usage do
  let(:usage){FactoryGirl.build :usage}

  describe "#is_taggable?" do
    subject{usage.is_taggable?}
    it{should be false}
  end
end
