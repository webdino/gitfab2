require 'spec_helper'

describe Attachment do
  let(:attachment) do
    FactoryGirl.build :attachment_material
  end

  describe '#dup_document' do
    subject { attachment.dup_document }
    it { expect(subject).to be_a(Attachment) }
    it { expect(subject).to_not eq(attachment) }
    it { expect(subject.title).to eq(attachment.title) }
    it { expect(subject.kind).to eq(attachment.kind) }
    it { expect(subject.content).to_not eq(attachment.content) }
    describe 'content' do
      it { expect(subject.content.model).to eq(subject) }
      it { expect(subject.content.filename).to eq(attachment.content.filename) }
      it { expect(subject.content.file.size).to eq(attachment.content.file.size) }
      it { expect(subject.content.file.content_type).to eq(attachment.content.file.content_type) }
    end
  end
end
