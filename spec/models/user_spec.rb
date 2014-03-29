require "spec_helper"

describe User do
  before do
    Dir.glob("#{Settings.git.repo_dir}/*").each{|path| FileUtils.rm_rf path}
  end

  let(:user){FactoryGirl.build :user}

  describe "using valid factory" do
    it{expect(user).to be_valid}
  end

  describe ".dir_path" do
    it{expect(user.dir_path).to eq "#{Settings.git.repo_dir}/#{user.name}"}
  end

  describe "after_save" do
    describe ".ensure_dir_exist!" do
      context "when the user has a name" do
        describe "creates a dir if not exists" do
          before{user.send :ensure_dir_exist!}
          subject{::File.exists? user.dir_path.to_s}
          it{should be_true}
        end
      end
      context "when the user doesn't have a name" do
        before do
          user.name = ""
          user.send :ensure_dir_exist!
        end
        subject{::File.exists? user.dir_path.to_s}
        it{should be_false}
      end
    end
  end

end
