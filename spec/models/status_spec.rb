require "spec_helper"

describe Status do
  let(:user){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :recipe, user: user}
  let(:status){FactoryGirl.create :status, recipe: recipe}

  describe "#to_path" do
    subject{status.to_path}
    it{should be_a String}
  end
end
