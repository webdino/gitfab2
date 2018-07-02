# frozen_string_literal: true

shared_examples 'ProjectOwner' do |*factory_args|
  describe '#projects' do
    let(:owner) { FactoryBot.create(*factory_args) }

    it { expect(owner).to respond_to(:projects) }
  end

  describe '#projects_count' do
    let(:owner) { FactoryBot.create(*factory_args) }

    it { expect(owner).to respond_to(:projects_count) }

    it 'プロジェクトをprivateからpublicにした際にカウントアップすること' do
      project = FactoryBot.create(:user_project, is_private: true, owner: owner)
      expect { project.update(is_private: false) }.to change(owner, :projects_count).by(1)
    end

    it 'プロジェクトをpublicからprivateにした際にカウントダウンすること' do
      project = FactoryBot.create(:user_project, is_private: false, owner: owner)
      expect { project.update(is_private: true) }.to change(owner, :projects_count).by(-1)
    end

    it 'publicなプロジェクトを作成した際にカウントアップすること' do
      project = FactoryBot.build(:user_project, is_private: false, owner: owner)
      expect { project.save! }.to change(owner, :projects_count).by(1)
    end

    it 'privateなプロジェクトを作成した際にカウントアップしないこと' do
      project = FactoryBot.build(:user_project, is_private: true, owner: owner)
      expect { project.save! }.to_not change(owner, :projects_count)
    end

    it 'publicなプロジェクトを論理削除した際にカウントダウンすること' do
      project = FactoryBot.create(:user_project, is_private: false, owner: owner)
      expect { project.soft_destroy! }.to change(owner, :projects_count).by(-1)
    end

    it 'privateなプロジェクトを論理削除した際にカウントダウンしないこと' do
      project = FactoryBot.create(:user_project, is_private: true, owner: owner)
      expect { project.soft_destroy! }.to_not change(owner, :projects_count)
    end

    it 'publicなプロジェクトを削除した際にカウントダウンすること' do
      project = FactoryBot.create(:user_project, is_private: false, owner: owner)
      expect { project.destroy! }.to change(owner, :projects_count).by(-1)
    end

    it 'privateなプロジェクトを削除した際にカウントダウンしないこと' do
      project = FactoryBot.create(:user_project, is_private: true, owner: owner)
      expect { project.destroy! }.to_not change(owner, :projects_count)
    end

    it '論理削除済みのpublicプロジェクトを削除した際にカウントダウンしないこと' do
      project = FactoryBot.create(:user_project, :soft_destroyed, is_private: false, owner: owner)
      expect { project.destroy! }.to_not change(owner, :projects_count)
    end

    it '論理削除済みのprivateプロジェクトを削除した際にカウントダウンしないこと' do
      project = FactoryBot.create(:user_project, :soft_destroyed, is_private: true, owner: owner)
      expect { project.destroy! }.to_not change(owner, :projects_count)
    end

    it '論理削除済みのpublicプロジェクトを復元した際にカウントアップすること' do
      project = FactoryBot.create(:user_project, :soft_destroyed, is_private: false, owner: owner)
      expect { project.soft_restore! }.to change(owner, :projects_count).by(1)
    end

    it '論理削除済みのprivateプロジェクトを復元した際にカウントアップしないこと' do
      project = FactoryBot.create(:user_project, :soft_destroyed, is_private: true, owner: owner)
      expect { project.soft_restore! }.to_not change(owner, :projects_count)
    end

    it 'privateなプロジェクトをpublicにしつつ論理削除した際にカウントアップもダウンもしないこと' do
      project = FactoryBot.create(:user_project, is_private: true, owner: owner)
      expect { project.update(is_private: false, is_deleted: true) }.to_not change(owner, :projects_count)
    end

    it 'publicなプロジェクトをprivateにしつつ論理削除した際にカウントダウンすること' do
      project = FactoryBot.create(:user_project, is_private: false, owner: owner)
      expect { project.update(is_private: true, is_deleted: true) }.to change(owner, :projects_count).by(-1)
    end

    it 'privateなプロジェクトをpublicにしつつ復元した際ににカウントアップすること' do
      project = FactoryBot.create(:user_project, :soft_destroyed, is_private: true, owner: owner)
      expect { project.update(is_private: false, is_deleted: false) }.to change(owner, :projects_count).by(1)
    end

    it 'publicなプロジェクトをprivateにしつつ復元した際にカウントアップもダウンもしないこと' do
      project = FactoryBot.create(:user_project, :soft_destroyed, is_private: false, owner: owner)
      expect { project.update(is_private: true, is_deleted: false) }.to_not change(owner, :projects_count)
    end
  end
end
