class NameFormatValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    unless /^[a-zA-Z0-9][a-zA-Z0-9\-]*$/ === value && /[^\-]$/ === value
      record.errors[attribute] << " or permalink is invalid format."
    end
  end
end
