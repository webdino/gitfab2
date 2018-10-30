# frozen_string_literal: true

describe UserDecorator do
  it_behaves_like "OGP Interface Test", User

  let(:user) do
    user = FactoryBot.create(:user, name: name, avatar: image)
    user.extend(UserDecorator)
  end
  let(:name) { "itkrt2y" }
  let(:image) { fixture_file_upload("images/image.jpg") }

  describe "#name" do
    subject { user.name }
    let(:user) { FactoryBot.create(:user, is_deleted: is_deleted, name: name).extend(UserDecorator) }
    let(:name) { "user-name" }

    context "when active user" do
      let(:is_deleted) { false }
      it { is_expected.to eq name }
    end

    context "when resigned user" do
      let(:is_deleted) { true }
      it { is_expected.to eq "Deleted User" }
    end
  end

  describe "#ogp_title" do
    context "when name exists" do
      it { expect(user.ogp_title).to eq "#{name} on Fabble" }
    end

    context "when name does not exist" do
      let(:user) { User.new.extend(UserDecorator) }
      it { expect(user.ogp_title).to be nil }
    end
  end

  describe "#ogp_description" do
    it { expect(user.ogp_description).to be nil }
  end

  describe "#ogp_image" do
    let(:base_url) { "https://fabble.cc" }

    context "when avatar exists" do
      it { expect(user.ogp_image(base_url)).to eq "#{base_url}#{user.avatar.url}" }
    end

    context "when avatar does not exist" do
      let(:user) { User.new.extend(UserDecorator) }
      it { expect(user.ogp_image(base_url)).to be nil }
    end
  end

  describe "#ogp_video" do
    it { expect(user.ogp_video).to be nil }
  end
end
