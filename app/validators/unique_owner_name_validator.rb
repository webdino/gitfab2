class UniqueOwnerNameValidator < ActiveModel::EachValidator
  def validate record
    unless record.name
      record.errors[:name] << " is nil"
      return
    end
    _rec = User.find(record.name)
    _rec ||= Group.find(record.name)
    if _rec && record != _rec
      record.errors[:name] << "has already been taken."
    end
  end
end