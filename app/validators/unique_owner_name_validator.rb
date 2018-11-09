class UniqueOwnerNameValidator < ActiveModel::EachValidator
  def validate(record)
    unless record.name
      record.errors[:name] << ' is nil'
      return
    end
    slug = record.normalize_friendly_id(record.name)
    if User.where(slug: slug).where.not(id: record.id).exists? || Group.where(slug: slug).where.not(id: record.id).exists?
      record.errors[:name] << 'has already been taken.'
    end
  end
end
