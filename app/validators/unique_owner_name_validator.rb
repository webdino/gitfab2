class UniqueOwnerNameValidator < ActiveModel::EachValidator
  def validate record
    if User.find_by(slug: record.name) || Group.find_by(slug: record.name)
      record.errors[:name] << "has been alreadly taken."
    end
  end
end
