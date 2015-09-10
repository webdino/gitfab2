module ItemsHelper
  def item
    instance_variable_get "@#{controller_name.singularize}"
  end

  def item=(val)
    instance_variable_set "@#{controller_name.singularize}", val
  end
end
