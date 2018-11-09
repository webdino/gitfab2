# use this script like
# $bundle exec rails runner "eval(File.read 'script/recreate_versions.rb')"

Project.all.each do |project|
  project.figures.each do |figure|
    figure.content.recreate_versions! if figure.content.present?
  end

  project.note_cards.each do |note_card|
    note_card.figures.each do |figure|
      figure.content.recreate_versions! if figure.content.present?
    end
  end
end
