require "spec_helper"

describe Status do
  disconnect_sunspot
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:status){FactoryGirl.create :status, recipe: recipe}

  describe "#to_path" do
    subject{status.to_path}
    it{should be_a String}
  end
end
