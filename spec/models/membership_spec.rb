require "spec_helper"

describe Membership do
  let(:membership){FactoryGirl.build :membership}
  describe "#owner?" do
    before{membership.role = Membership::ROLE[:owner]}
    subject{membership.owner?}
    it{should be true}
  end
end
