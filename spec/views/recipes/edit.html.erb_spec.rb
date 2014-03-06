require 'spec_helper'

describe "recipes/edit" do
  before(:each) do
    @recipe = assign(:recipe, stub_model(Recipe,
      :title => "MyString",
      :description => "MyText",
      :user => nil
    ))
  end

  it "renders the edit recipe form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", recipe_path(@recipe), "post" do
      assert_select "input#recipe_title[name=?]", "recipe[title]"
      assert_select "textarea#recipe_description[name=?]", "recipe[description]"
      assert_select "input#recipe_user[name=?]", "recipe[user]"
    end
  end
end
