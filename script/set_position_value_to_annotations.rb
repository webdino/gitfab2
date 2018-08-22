# use this script like
# $bundle exec rails runner "eval(File.read 'script/set_position_value_to_annotations.rb')"

Project.all.each do |project|
  project.states.each do |state|
    state.annotations.each.with_index(1) do |annotation, index|
      annotation.position = index
      annotation.save
    end
  end
end
