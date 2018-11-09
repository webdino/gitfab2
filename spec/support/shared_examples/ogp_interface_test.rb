# frozen_string_literal: true

shared_examples "OGP Interface Test" do |klass|
  subject { ActiveDecorator::Decorator.instance.decorate(klass.new) }

  describe "#ogp_title" do
    it { is_expected.to respond_to(:ogp_title) }
  end

  describe "#ogp_description" do
    it { is_expected.to respond_to(:ogp_description) }
  end

  describe "#ogp_image" do
    it { is_expected.to respond_to(:ogp_image) }
  end

  describe "#ogp_video" do
    it { is_expected.to respond_to(:ogp_video) }
  end
end
