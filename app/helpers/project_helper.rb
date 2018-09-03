# frozen_string_literal: true

module ProjectHelper
  def all_tags
    Tag.where.not(name: '').group(:name).order(Arel.sql('COUNT(id) DESC')).pluck(:name)
  end

  def selected_tags
    all_tags[0..30]
  end

  def selected_tools
    [
      "laser cutter", "cutting machine", "Autodesk Fusion 360", "3d printer",
      "milling machine", "CNC Router", "Firefox", "Arduino"
    ]
  end

  def selected_materials
    ["wood", "leather", "MDF", "paper", "Arduino", "Open Web Board"]
  end
end
