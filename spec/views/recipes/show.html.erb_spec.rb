require 'spec_helper'

describe "recipes/show" do
  before(:each) do
    @recipe = assign(:recipe, stub_model(Recipe,
      :title => "Title",
      :description => "MyText",
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(//)
  end
end
