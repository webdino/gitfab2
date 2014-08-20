class NameFormatValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    unless /^[a-zA-Z0-9][a-zA-Z0-9\-]*$/ === value && /[^\-]$/ === value
      record.errors[attribute] << " or permalink should be [a-zA-Z0-9] and '-'."
    end
  end
end
