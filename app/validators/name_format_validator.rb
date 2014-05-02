class NameFormatValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    unless /^[a-zA-Z]\w{3,}$/ === value
      record.errors[attribute] << "is invalid format for #{attribute}."
    end
  end
end
