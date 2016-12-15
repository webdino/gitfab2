require "spec_helper"

describe Forkable do
  class ForkableClass
    include Forkable
  end

  def same_contents? ary1, ary2
    ary1 - ary2 == []
  end

  describe "#replace_with_a_derivative" do
    let!(:forkable){ForkableClass.new}
    let!(:derivative1){forkable.derivatives.build}
    let!(:derivative2){forkable.derivatives.build}
    subject do
      forkable.replace_with_a_derivative derivative1
    end
    it{should have(2).derivatives}
    it{expect(subject.derivatives).to eq [forkable, derivative2]}
  end
end
