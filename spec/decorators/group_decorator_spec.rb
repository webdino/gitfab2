# frozen_string_literal: true

describe GroupDecorator do
  it_behaves_like "OGP Interface Test", Group

  let(:group) { FactoryBot.create(:group, name: name, avatar: avatar).extend(GroupDecorator) }
  let(:name) { "my-fabble-group" }
  let(:avatar) { fixture_file_upload('images/image.jpg') }

  describe "#ogp_title" do
    context "when name exists" do
      it { expect(group.ogp_title).to eq "#{name} on Fabble" }
    end

    context "when name does not exist" do
      let(:group) { Group.new.extend(GroupDecorator) }
      it { expect(group.ogp_title).to be nil }
    end
  end

  describe "#ogp_description" do
    it { expect(group.ogp_description).to be nil }
  end

  describe "#ogp_image" do
    let(:base_url) { "https://fabble.cc" }

    context "when avatar exists" do
      it { expect(group.ogp_image(base_url)).to eq "#{base_url}#{group.avatar.url}" }
    end

    context "when avatar does not exist" do
      let(:group) { Group.new.extend(GroupDecorator) }
      it { expect(group.ogp_image(base_url)).to be nil }
    end
  end

  describe "#ogp_video" do
    it { expect(group.ogp_video).to be nil }
  end
end
