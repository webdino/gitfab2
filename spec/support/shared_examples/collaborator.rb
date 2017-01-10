shared_examples 'Collaborator' do |*factory_args|
  let(:collaborator) { FactoryGirl.create(*factory_args) }
  let(:collaboration) { FactoryGirl.create(:collaboration, owner: collaborator) }

  describe '#collaborations' do
    it do
      expect(collaborator).to be_respond_to(:collaborations)
    end

    it do
      expect(collaborator.collaborations).to be_member(collaboration)
    end
  end

  describe '#is_collaborator_of?(project)' do
    let(:project) { collaboration.project }

    it do
      expect(collaborator).to be_respond_to(:is_collaborator_of?)
    end

    it 'レシーバがprojectをコラボしているなら真を返すこと' do
      expect(collaborator.is_collaborator_of?(project)).to be_truthy
    end

    it 'レシーバがprojectをコラボしていないなら偽を返すこと' do
      not_collaborated_project = FactoryGirl.create(:user_project)
      expect(collaborator.is_collaborator_of?(not_collaborated_project)).to be_falsey
    end
  end

  describe '#collaboration_in(project)' do
    let(:project) { collaboration.project }

    it do
      expect(collaborator).to be_respond_to(:collaboration_in)
    end

    it 'レシーバにcollaborationがあるなら返すこと' do
      expect(collaborator.collaboration_in(project)).to eq(collaboration)
    end

    it 'レシーバにcollaborationがないならnilを返すこと' do
      not_collaborated_project = FactoryGirl.create(:user_project)
      other_collaboration = FactoryGirl.create(:collaboration,
                                               project: not_collaborated_project)
      expect(collaborator.collaboration_in(not_collaborated_project)).to be_nil
    end
  end

  describe '#collaborate!(project)' do
    it do
      expect(collaborator).to be_respond_to(:collaboration_in)
    end

    it 'レシーバがprojectをコラボレートすること' do
      new_project = FactoryGirl.create(:user_project)
      expect {
        collaborator.collaborate!(new_project)
      }.to change { collaborator.is_collaborator_of?(new_project) }
    end

    it 'returns an instance of Collaboration.' do
      new_project = FactoryGirl.create(:user_project)
      expect(collaborator.collaborate!(new_project)).to be_an_instance_of(Collaboration)
    end
  end
end
