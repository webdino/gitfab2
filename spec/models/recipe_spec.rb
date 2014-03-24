require "spec_helper"
require "sunspot/rails/spec_helper"

describe Recipe do
  disconnect_sunspot
  before do
    Dir.glob("/home/git/repositories_test/*").each{|path| FileUtils.rm_rf path}
  end

  let(:user){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :recipe, user: user}

  describe "#commit!" do
    let(:repo){recipe.repo}
    describe "creates a new commit" do
      before do
        recipe.commit!
      end
      subject{recipe.repo.head.target}
      it{should be_a String}
    end
    describe "saves the repo tree" do
      let(:tree){recipe.repo.lookup(repo.head.target).tree}
      before do
        recipe.statuses.create description: "st1"
        st2 = recipe.statuses.create description: "st2"
        st2.ways.create description: "wy1"
        recipe.materials.create description: "mt1"
        recipe.materials.create description: "mt2"
        recipe.tools.create description: "mt2"
        recipe.commit!
        tree
      end
      describe "with dirs" do
        let(:dirs){Array.new.tap{|arr| tree.each_tree{|entry| arr << entry[:name]}}}
        subject{dirs.size}
        it{should be 4}
      end
      describe "with items in each dirs" do
        let(:items) do
          Array.new.tap do |arr|
            tree.each_tree do |t_entry|
              dir = repo.lookup t_entry[:oid]
              dir.each_blob do |b_entry|
                arr << b_entry[:name]
              end
            end
          end
        end
        subject{items.size}
        it{should be 6}
      end
    end
  end

  describe "#fork_for!" do
    let(:other){FactoryGirl.create :user}
    let(:forked_recipe){recipe.fork_for! other}
    let(:forked_recipe2){recipe.fork_for! other}

    context "when a repository which has duplicated name doesn't exists" do
      describe "produces a new repo forked from the original repo" do
        subject{File.exists? forked_recipe.repo.path}
        it{should be_true}
      end
    end

    context "when a repository which has duplicated name already exists" do
      let(:forked_recipe2){recipe.fork_for! other}
      before do
        forked_recipe
        forked_recipe2
      end
      describe "produces a new repo forked from the original repo" do
        subject{File.exists? forked_recipe2.repo.path}
        it{should be_true}
      end
      describe "produces a new repo suffixed with underscore(s)" do
        subject{forked_recipe2.repo.path}
        it{should eq forked_recipe.repo.path.sub!(/\.git\/$/, "_.git/")}
      end
    end
  end

  describe "on after_update" do
    describe "#rename_repo_name!" do
      let!(:orig_repo_path){recipe.repo.path}
      before{recipe.update_attributes name: "#{recipe.name}_modified"}
      subject{recipe.repo.path}
      it{should_not eq orig_repo_path}
    end
  end

  describe "on after_destroy" do
    describe "#destroy_repo!" do
      before{recipe.destroy}
      subject{recipe.repo}
      it{should be nil}
    end
  end

  describe "can have tags" do
    before do
      recipe.tags << Tag.new(name: "foo")
      recipe.tags << Tag.new(name: "bar")
    end
    subject{recipe}
    its(:tags){should have(2).items}
  end
end
