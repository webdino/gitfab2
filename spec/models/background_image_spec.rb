# frozen_string_literal: true

describe BackgroundImage do
  let(:background_image) { BackgroundImage.new(file: file) }
  let(:file) { nil }
  let(:image_file) { fixture_file_upload("images/image.jpg", content_type) }
  let(:content_type) { "image/jpeg" }

  describe ".find" do
    subject { BackgroundImage.find }

    context "with file" do
      let(:file) { image_file }
      before { background_image.save }
      xit { is_expected.to be_kind_of BackgroundImage }
    end

    context "without file" do
      before { allow(BackgroundImage).to receive(:exists?).and_return(false) }
      it { is_expected.to be nil }
    end
  end

  describe ".basename" do
    it { expect(BackgroundImage.basename).to eq "background_image.jpg" }
  end

  describe ".path" do
    it { expect(BackgroundImage.path).to eq Rails.root.join("public", "uploads", BackgroundImage.basename) }
  end

  describe "#basename" do
    it { expect(background_image.basename).to eq "background_image.jpg" }
  end

  describe "#path" do
    it { expect(background_image.path).to eq Rails.root.join("public", "uploads", background_image.basename) }
  end

  describe "#content_type" do
    subject { background_image.content_type }

    context "with file" do
      let(:file) { image_file }
      it { is_expected.to eq content_type }
    end

    context "without file" do
      it { is_expected.to be nil }
    end
  end

  describe "#request_uri" do
    subject { background_image.request_uri }

    context "with file" do
      let(:file) { image_file }
      let(:timestamp) { Time.current.to_i.to_s }
      before { allow(background_image).to receive(:timestamp).and_return(timestamp) }
      it { is_expected.to eq "/uploads/background_image.jpg?t=#{timestamp}" }
    end

    context "without file" do
      it { is_expected.to be nil }
    end
  end

  describe "#save" do
    subject { background_image.save }

    context "with file" do
      let(:file) { image_file }

      context "when file is jpeg" do
        xit do
          expect(FileUtils).to receive(:cp).with(file.tempfile.path, background_image.path).and_call_original
          expect(FileUtils).to receive(:chmod).with(0644, background_image.path).and_call_original
          is_expected.to be true
        end
      end

      context "when file is not jpeg" do
        let(:content_type) { "text/plain" }
        it { is_expected.to be false }
      end
    end

    context "without file" do
      it { is_expected.to be false }
    end
  end
end
