require "spec_helper"

describe Membership do
  let(:membership){FactoryGirl.build :membership}
  describe "#admin?" do
    before{membership.role = Membership::ROLE[:admin]}
    subject{membership.admin?}
    it{should be true}
  end
end
