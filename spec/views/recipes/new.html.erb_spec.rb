require 'spec_helper'

describe "recipes/new" do
  before(:each) do
    assign(:recipe, stub_model(Recipe,
      :title => "MyString",
      :description => "MyText",
      :user => nil
    ).as_new_record)
  end

  it "renders new recipe form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", recipes_path, "post" do
      assert_select "input#recipe_title[name=?]", "recipe[title]"
      assert_select "textarea#recipe_description[name=?]", "recipe[description]"
      assert_select "input#recipe_user[name=?]", "recipe[user]"
    end
  end
end
