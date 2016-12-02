class UniqueOwnerNameValidator < ActiveModel::EachValidator
  def validate(record)
    unless record.name
      record.errors[:name] << ' is nil'
      return
    end
    rec = User.find_by_slug(record.normalize_friendly_id(record.name))
    rec ||= Group.find_by_slug(record.normalize_friendly_id(record.name))
    record.errors[:name] << 'has already been taken.' if rec && record != rec
  end
end
