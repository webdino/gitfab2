# frozen_string_literal: true

shared_examples 'ProjectOwner' do |*factory_args|
  describe '#projects' do
    let(:owner) { FactoryBot.create(*factory_args) }
    it { expect(owner).to respond_to(:projects) }
  end

  describe '#soft_destroy_all!' do
    let(:owner) { FactoryBot.create(*factory_args) }
    before do
      FactoryBot.create(:project, owner: owner, is_deleted: true)
      FactoryBot.create(:project, owner: owner, is_deleted: false)
    end
    it { expect{ owner.projects.soft_destroy_all! }.to change{ Project.where(is_deleted: true).count }.from(1).to(2) }
    it do
      expect_any_instance_of(Project).to receive(:soft_destroy!).once
      owner.projects.soft_destroy_all!
    end
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
