# frozen_string_literal: true

describe ProjectDecorator do
  it_behaves_like "OGP Interface Test", Project

  let(:project) do
    project = FactoryBot.create(:project, title: title, description: description, owner: owner)
    project.extend(ProjectDecorator)
  end
  let(:title) { "My Fabble Project Title" }
  let(:description) { "My Fabble Project Description" }
  let(:owner) { FactoryBot.create(:user, name: owner_name) }
  let(:owner_name) { "owner-name" }

  describe "#first_figure" do
    before do
      FactoryBot.create(:figure, figurable: project)
      FactoryBot.create(:figure, figurable: project)
    end
    it { expect(project.first_figure).to eq project.figures.first }
  end

  describe "#ogp_title" do
    context "when title exists" do
      it { expect(project.ogp_title).to eq "#{title} by #{owner_name}" }
    end

    context "when title does not exist" do
      let(:project) { Project.new.extend(ProjectDecorator) }
      it { expect(project.ogp_title).to be nil }
    end
  end

  describe "#ogp_description" do
    it { expect(project.ogp_description).to eq description }
  end

  describe "#ogp_image" do
    let(:base_url) { "https://fabble.cc" }
    let!(:figure) { FactoryBot.create(:content_figure, figurable: project) }
    it { expect(project.ogp_image(base_url)).to eq "#{base_url}#{figure.content.url}" }
  end

  describe "#ogp_video" do
    let!(:figure) { FactoryBot.create(:link_figure, figurable: project) }
    it { expect(project.ogp_video).to eq figure.link }
  end

  describe "#parent_license_index" do
    subject { project.parent_license_index }

    context "when forked project" do
      let(:original) { FactoryBot.create(:project, license: "by-nc") }
      before { project.update!(original: original) }
      it { is_expected.to eq Project.licenses[original.license] }
    end

    context "when original project" do
      it { is_expected.to eq 0 }
    end
  end

  describe "#license_url" do
    let!(:project) { Project.new(license: license).extend(ProjectDecorator) }
    let(:license) { "by-nc" }
    it { expect(project.license_url).to eq "https://creativecommons.org/licenses/#{license}/4.0" }
  end

  describe "#license_message"

  describe "#thumbnail" do
    context "YouTube動画が設定されている時" do
      before { FactoryBot.create(:figure, figurable: project, link: link) }
      let(:link) { "figure_link" }
      it "動画サムネイルURLを返すこと" do
        expect(project.thumbnail).to eq("https://img.youtube.com/vi/#{link}/mqdefault.jpg")
      end
    end

    context "画像が設定されている時" do
      let!(:figure) { FactoryBot.create(:content_figure, figurable: project) }
      it "画像サムネイルURLを返すこと" do
        expect(project.thumbnail).to eq("/uploads/figure/content/#{figure.id}/small_figure.png")
      end
    end

    context "画像・動画が設定されていない時" do
      it "規定のURLを返すこと" do
        expect(project.thumbnail).to eq("/images/fallback/blank.png")
      end
    end
  end

  describe "#thumbnail_fallback_path" do
    it { expect(project.thumbnail_fallback_path).to eq "/images/fallback/blank.png" }
  end
end
