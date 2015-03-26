require "spec_helper"

describe Card do
  let(:state) do
    FactoryGirl.build :state, title: "state1", description: "desc1"
  end

  describe "#dup_document" do
    context "with State" do
      subject{state.dup_document}
      it{expect(subject).to be_a Card::State}
      it{expect(subject.title).to eq state.title}
      it{expect(subject.description).to eq state.description}
    end
  end
end
