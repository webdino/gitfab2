require "spec_helper"
require "sunspot/rails/spec_helper"

describe Recipe do
  disconnect_sunspot
  before do
    Dir.glob("/home/git/repositories_test/*").each{|path| FileUtils.rm_rf path}
  end

  let(:user){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :recipe, user: user}

  describe ".fork_for!" do
    let(:other){FactoryGirl.create :user}
    let(:forked_recipe){recipe.fork_for! other}
    let(:forked_recipe2){recipe.fork_for! other}

    context "when a repository which has duplicated name doesn't exists" do
      describe "produces a new repo forked from the original repo" do
        subject{File.exists? forked_recipe.repo_path}
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
        subject{File.exists? forked_recipe2.repo_path}
        it{should be_true}
      end
      describe "produces a new repo suffixed with underscore(s)" do
        subject{forked_recipe2.repo_path}
        it{should eq forked_recipe.repo_path.sub!(/\.git$/, "_.git")}
      end
    end
  end

  describe "on after_create" do
    describe ".ensure_repo_exist!" do
      subject{File.exists? recipe.repo_path}
      it{should be_true}
    end
  end

  describe "on after_update" do
    describe ".rename_repo_name!" do
      let!(:orig_repo_path){recipe.repo_path}
      before{recipe.update_attributes name: "#{recipe.name}_modified"}
      subject{recipe.repo_path}
      it{should_not eq orig_repo_path}
    end
  end

  describe "on after_save" do
    describe ".commit_to_repo!" do
      subject{Rugged::Repository.new(recipe.repo_path).head.target}
      it{should_not be nil}
    end
  end

  describe "on after_destroy" do
    describe ".destroy_repo!" do
      before{recipe.destroy}
      subject{File.exists? recipe.repo_path}
      it{should be_false}
    end
  end
end
