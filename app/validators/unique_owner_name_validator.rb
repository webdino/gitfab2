class UniqueOwnerNameValidator < ActiveModel::EachValidator
  def validate record
    _rec   = User.find_by slug: record.name
    _rec ||= Group.find_by slug: record.name
    if _rec && record != _rec
      record.errors[:name] << "has already been taken."
    end
  end
end
