# == Schema Information
#
# Table name: figures
#
#  id             :integer          not null, primary key
#  content        :string(255)
#  figurable_type :string(255)
#  link           :string(255)
#  oldid          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  figurable_id   :integer
#
# Indexes
#
#  index_figures_figurable  (figurable_type,figurable_id)
#

class Figure::Video < Figure
end
