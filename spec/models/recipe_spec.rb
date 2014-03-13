require "spec_helper"
require 'sunspot/rails/spec_helper'

describe Recipe do
  disconnect_sunspot
  before do
    Dir.glob("/home/git/repositories_test/*").each{|path| FileUtils.rm_rf path}
  end

  let(:user){FactoryGirl.create :user}
  let(:recipe){user.recipes.build FactoryGirl.build(:recipe).attributes}

  describe ".fork_for" do
    let(:other){FactoryGirl.create :user}
    before do
      recipe.save
    end
    subject{recipe.fork_for other}

    describe "produces a new recipe forked from an existing recipe" do
      its(:orig_recipe){should eq recipe}
    end

    describe "produces a new recipe belongs to the user who forked the original recipe" do
      its(:user){should eq other}
    end

    describe "doesn't fork the recipe which the user has already forked" do
      before{recipe.fork_for(other).save}
      subject{recipe.fork_for other}
      it{should be_nil}
    end
  end

  describe "on after_create" do
    describe ".ensure_repo_exist!" do
      before{recipe.save}
      subject{File.exists? recipe.repo_path}
      it{should be_true}
    end
  end

  describe "on after_save" do
    describe ".commit_to_repo!" do
      before do
        recipe.save
      end
      subject do
        Rugged::Repository.new(recipe.repo_path).head.target
      end
      it{should_not be nil}
    end
  end

end
