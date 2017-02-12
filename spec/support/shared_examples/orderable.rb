shared_examples 'Orderable' do |*factory_args|
  describe 'increment position' do
    let(:orderable) { FactoryGirl.create(*factory_args) }

    it do
      expect(orderable).to be_respond_to(:position)
    end

    it do
      expect(orderable.position).to_not be_nil
    end
  end
end

shared_examples 'Orderable Scoped incrementation' do |factory_args, scope|
  let(:orderable) { FactoryGirl.create(*factory_args) }

  it '同じscopeならincrementした値' do
    orderable = FactoryGirl.create(*factory_args)
    merged_attributes = (factory_args[1] || {}).merge(scope => orderable.send(scope))
    new_orderable = FactoryGirl.create(*factory_args, merged_attributes)
    expect(new_orderable.position).to eq(orderable.position.succ)
  end

  it '同じscopeがなければincrementしない値' do
    orderable = FactoryGirl.create(*factory_args)
    new_orderable = FactoryGirl.create(*factory_args)
    expect(new_orderable.position).to eq(orderable.position)
  end
end


