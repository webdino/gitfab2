require "spec_helper"

describe User do
  before do
    Dir.glob("#{Settings.git.repo_dir}/*").each{|path| FileUtils.rm_rf path}
  end

  let(:user1){FactoryGirl.build :user}
  let(:user2){FactoryGirl.build :user}

  describe "using valid factory" do
    it{expect(user1).to be_valid}
  end

  describe ".dir_path" do
    it{expect(user1.dir_path).to eq "#{Settings.git.repo_dir}/#{user1.name}"}
  end

  describe "after_save" do
    describe ".ensure_dir_exist!" do
      context "when the user has a name" do
        describe "creates a dir if not exists" do
          before{user1.send :ensure_dir_exist!}
          subject{::File.exists? user1.dir_path.to_s}
          it{should be_true}
        end
      end
      context "when the user doesn't have a name" do
        before do
          user1.name = ""
          user1.send :ensure_dir_exist!
        end
        subject{::File.exists? user1.dir_path.to_s}
        it{should be_false}
      end
    end
  end

end
