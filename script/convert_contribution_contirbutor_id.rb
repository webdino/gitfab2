# use this script like
# $bundle exec rails runner "eval(File.read 'script/convert_contribution_contirbutor_id.rb')"

def convert contribution
  user = User.where(_slugs: contribution.contributor_id).first
  if user.present?
    contribution.contributor_id = user.id
    contribution.save
  else
    contribution.delete
  end
end

Project.all.each do |project|
  project.recipe.states.each do |state|
    state.contributions.each {|contribution| convert(contribution)}
    state.annotations.each do |annotation|
      annotation.contributions.each {|contribution| convert(contribution)}
    end
  end
  project.usages.each do |usage|
    usage.contributions.each {|contribution| convert(contribution)}
  end
  project.note_cards do |card|
    card.contributions.each {|contribution| convert(contribution)}
  end
end
