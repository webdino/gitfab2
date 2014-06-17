require "spec_helper"

describe Card::Annotation do
  let(:annotation){FactoryGirl.build :annotation}

  describe "#is_taggable?" do
    subject{annotation.is_taggable?}
    it{should be false}
  end
end
