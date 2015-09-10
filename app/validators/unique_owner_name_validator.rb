class UniqueOwnerNameValidator < ActiveModel::EachValidator
  def validate(record)
    unless record.name
      record.errors[:name] << ' is nil'
      return
    end
    _rec = User.find(record.name)
    _rec ||= Group.find(record.name)
    record.errors[:name] << 'has already been taken.' if _rec && record != _rec
  end
end
