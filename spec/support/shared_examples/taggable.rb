shared_examples 'Taggable' do |*factory_args|
  describe '#tags' do
    let(:taggable) { FactoryGirl.create(*factory_args) }
    it do
      expect(taggable).to be_respond_to(:tags)
    end

    it do
      tag = FactoryGirl.create(:tag, taggable: taggable)
      expect(taggable.reload.tags).to be_member(tag)
    end
  end
end
