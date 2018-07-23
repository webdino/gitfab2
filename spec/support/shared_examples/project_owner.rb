# frozen_string_literal: true

shared_examples 'ProjectOwner' do |*factory_args|
  describe '#projects' do
    let(:owner) { FactoryBot.create(*factory_args) }

    it { expect(owner).to respond_to(:projects) }
  end

  describe '#projects_count' do
    let(:owner) { FactoryBot.create(*factory_args) }

    it 'counts published projects' do
      one   = FactoryBot.create(:project, owner: owner, is_private: false, is_deleted: false)
      two   = FactoryBot.create(:project, owner: owner, is_private: false, is_deleted: false)
      three = FactoryBot.create(:project, owner: owner, is_private: false, is_deleted: false)
      expect(owner.projects_count).to eq 3

      one.update(is_private: true)
      expect(owner.projects_count).to eq 2

      two.update(is_deleted: true)
      expect(owner.projects_count).to eq 1

      three.destroy
      expect(owner.projects_count).to eq 0
    end
  end
end
