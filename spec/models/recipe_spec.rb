require "spec_helper"

describe Recipe do
  disconnect_sunspot
  before do
    Dir.glob("#{Settings.git.repo_dir}/*").each{|path| FileUtils.rm_rf path}
  end

  let(:user){FactoryGirl.create :user}
  let(:group){FactoryGirl.create :group, creator: user}
  let(:recipe){FactoryGirl.create :recipe, user: user}
  let(:g_recipe){FactoryGirl.create :recipe, group: group}
  let(:status){FactoryGirl.create :status, recipe: recipe}
  let(:way){FactoryGirl.create :way, recipe: recipe}
  let(:tool){FactoryGirl.create :tool, recipe: recipe}
  let(:material){FactoryGirl.create :material, recipe: recipe}

  describe "#owner" do
    context "when owned by a user" do
      subject{recipe.owner}
      it{should eq user}
    end
    context "when owned by a group" do
      subject{g_recipe.owner}
      it{should eq group}
    end
  end

  describe "#commit!" do
    let(:repo){recipe.repo}
    describe "creates a new commit" do
      before do
        status
        recipe.commit!
      end
      subject{recipe.repo.head.target}
      it{should be_a String}
    end
    describe "saves the repo tree" do
      let(:tree){recipe.repo.lookup(repo.head.target).tree}
      let(:assocs){[:statuses, :ways, :materials, :tools]}
      before do
        assocs.each do |assoc|
          2.times do |i|
            recipe.send(assoc).create description: "#{assoc}#{i}"
          end
        end
        recipe.commit!
        tree
      end
      describe "with dirs" do
        let(:dirs){Array.new.tap{|arr| tree.each_tree{|entry| arr << entry[:name]}}}
        subject{dirs.size}
        it{should be assocs.size}
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
        it{should be 8}
      end
    end
  end

  describe "#fork_for!" do
    let(:other){FactoryGirl.create :user}
    let(:forked_recipe){recipe.fork_for! other}
    let(:forked_recipe2){recipe.fork_for! other}
    before do
      status; way; tool; material;
      recipe.commit!
    end

    Recipe::ASSOCS.each do |assoc|
      describe "copies photo of #{assoc}" do
        subject{File.exists? forked_recipe.send(assoc).first.photo.path}
        it{should be_true}
      end
    end

    context "when a repository which has duplicated name doesn't exists" do
      describe "produces a new repo forked from the original repo" do
        subject{Dir.exists? forked_recipe.repo.path}
        it{should be_true}
      end
    end

    context "when a repository which has duplicated name already exists" do
      let(:forked_recipe2){recipe.fork_for! other}
      before do
        status
        forked_recipe
        forked_recipe2
      end
      describe "produces a new repo forked from the original repo" do
        subject{Dir.exists? forked_recipe2.repo.path}
        it{should be_true}
      end
      describe "produces a new repo suffixed with underscore(s)" do
        subject{forked_recipe2.repo.path}
        it{should eq forked_recipe.repo.path.sub!(/\.git\/$/, "_.git/")}
      end
    end

    context "when the repository has items which don't have photo" do
      before do
        recipe.statuses.create
        recipe.ways.create
        recipe.tools.create
        recipe.materials.create
      end
      subject{recipe.fork_for! other}
      it{should be_a Recipe}
    end
  end

  describe "on after_create" do
    describe "#ensure_repo_exist!" do
      context "with group recipe" do
        subject{g_recipe.repo.path}
        it{should eq "#{g_recipe.group.dir_path}/#{g_recipe.name}.git/"}
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
