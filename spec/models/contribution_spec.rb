require 'spec_helper'

describe Contribution do
  it_behaves_like 'Contributable', :contribution

  describe "#contributor" do
    let(:contribution) { FactoryGirl.create(:contribution) }
    it { expect(contribution).to be_respond_to(:contributor) }
    it { expect(contribution.contributor).to be_an_instance_of(User) }
  end

  describe "#contributable" do
    let(:contribution) { FactoryGirl.create(:contribution) }
    it { expect(contribution).to be_respond_to(:contributable) }
    it { expect(contribution.contributable.class).to be_include(Contributable) }
  end

end
