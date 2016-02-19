# use this script like
# $bundle exec rails runner "eval(File.read 'script/convert_figure_links.rb')"

def convert _obj
  if _obj.figures.length == 1 && _obj.figures.first.link.present?
    _obj.figures.first.link = _obj.figures.first.link.gsub("http://", "https://")
    _obj.save!
  end
end

Project.all.each do |project|
  convert(project)
  project.recipe.states.each do |state|
    convert(state)
    state.annotations.each {|annotation| convert(annotation)}
  end
  project.usages.each {|usage| convert(usage)}
  project.note.note_cards.each {|card| convert(card)}
end
