require "spec_helper"

describe Card do
  let(:state) do
    FactoryGirl.build :state, title: "state1", description: "desc1"
  end
  let(:transition) do
    FactoryGirl.build :transition, title: "transition1", description: "desc1"
  end

  describe "#dup_document" do
    context "with State" do
      subject{state.dup_document}
      it{expect(subject).to be_a Card::State}
      it{expect(subject.title).to eq state.title}
      it{expect(subject.description).to eq state.description}
    end

    context "with Transition" do
      subject{transition.dup_document}
      it{expect(subject).to be_a Card::Transition}
      it{expect(subject.title).to eq transition.title}
      it{expect(subject.description).to eq transition.description}
    end
  end
end
