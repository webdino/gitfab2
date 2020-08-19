puts "Create owners"

new_users = FactoryBot.build_list(:user, 100)
User.import(new_users)
users = User.where(name: new_users.map(&:name))

new_groups = 10.times.map do
  members = users.sample(rand(1..5))
  FactoryBot.build(:group, members: members)
end
Group.import(new_groups)
groups = Group.where(name: new_groups.map(&:name))

puts "Create projects"

new_projects = users.map { |user| FactoryBot.build_list(:user_project, rand(0..10), owner: user) }.flatten + groups.map { |group| FactoryBot.build_list(:group_project, rand(0..5), owner: group) }.flatten
Project.import(new_projects)
projects = Project.where(name: new_projects.map(&:name))

puts "Create cards"

new_figures = []
new_note_cards = []
new_states = []
new_usages = []
project_comments = []

projects.each do |project|
  new_figures.concat FactoryBot.build_list(:link_figure, rand(0..5), figurable: project)
  new_figures.concat FactoryBot.build_list(:content_figure, rand(0..5), figurable: project)
  new_note_cards.concat FactoryBot.build_list(:note_card, rand(0..5), project: project)
  new_states.concat FactoryBot.build_list(:state, rand(0..5), project: project, annotations_count: 0)
  new_usages.concat FactoryBot.build_list(:usage, rand(0..5), project: project)
  project_comments.concat rand(0..5).times.map { FactoryBot.build(:project_comment, project: project, user: users.sample) }
end

Figure.import(new_figures)
Card::NoteCard.import(new_note_cards)
Card::State.import(new_states)
Card::Usage.import(new_usages)
ProjectComment.import(project_comments)

new_annotations = []
states = Card::State.where(project: projects)
states.each do |state|
  new_annotations.concat FactoryBot.build_list(:annotation, rand(0..5), state: state)
end

Card::Annotation.import(new_annotations)
annotations = Card::Annotation.where(state: states)

puts "Create forked projects"

projects.sample(projects.count / 20).each do |project|
  target_owner = project.owner.is_a?(User) ? User.where(id: users).where.not(id: project.owner_id).sample : users.sample
  project.fork_for!(target_owner)
end

puts "Create comments"

new_card_comments = []
states.each do |state|
  new_card_comments.concat rand(0..5).times.map { FactoryBot.build(:card_comment, card: state, user: users.sample) }
end
annotations.each do |annotation|
  new_card_comments.concat rand(0..5).times.map { FactoryBot.build(:card_comment, card: annotation, user: users.sample) }
end

CardComment.import(new_card_comments)
card_comments = CardComment.where(card: states + annotations)

puts "Create likes"

new_likes = []
projects.each do |project|
  new_likes.concat rand(0..(users.length / 2)).times.map { |i| FactoryBot.build(:like, project: project, user: users[i]) }
end

puts "Create access logs"

new_project_access_logs = []
projects.each do |project|
  views = case rand(100)
  when 95..100
    rand(1000..5000)
  when 80...95
    rand(100..1000)
  when 30...80
    rand(10..100)
  else
    rand(10)
  end
  new_project_access_logs.concat views.times.map { FactoryBot.build(:project_access_log, project: project, user: [nil, users.sample].sample, created_at: rand((Time.current - project.created_at).to_i).seconds.ago) }
end
ProjectAccessLog.import(new_project_access_logs)

puts "Reset counters"

projects.each do |project|
  %i[likes note_cards project_access_logs states usages].each do |key|
    Project.reset_counters(project.id, key)
  end
end

(states + annotations).each do |card|
  Card.reset_counters(card.id, :comments)
end
