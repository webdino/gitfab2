# frozen_string_literal: true

shared_examples 'DraftInterfaceTest' do |obj|
  describe '#generate_draft' do
    it { expect(obj).to respond_to(:generate_draft) }
    it { expect(obj.generate_draft).to be_kind_of(String) }
  end
end
