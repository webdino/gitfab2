class NameFormatValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    unless /^[a-zA-Z0-9][a-zA-Z0-9_\-]{2,}$/ === value
      record.errors[attribute] << "is invalid format for #{attribute}."
    end
  end
end
