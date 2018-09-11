describe Owner do
  describe ".find" do
    let(:project) { FactoryBot.create(:project, owner: owner) }
    let(:owner) { FactoryBot.create(:group) }

    it "finds an owner" do
      expect(Owner.find(owner.slug)).to eq owner
    end
    it "raises an error if owner does not exist" do
      expect{ Owner.find("not_exist") }.to raise_error{ ActiveRecord::RecordNotFound }
    end
  end

  describe ".find_by" do
    let(:project) { FactoryBot.create(:project, owner: owner) }
    let(:owner) { FactoryBot.create(:user) }

    it "finds an owner" do
      expect(Owner.find_by(owner.slug)).to eq owner
    end
    it "returns nil if owner does not exist" do
      expect(Owner.find_by("not_exist")).to be nil
    end
  end
end
