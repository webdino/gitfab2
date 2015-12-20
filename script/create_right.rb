# use this script like
# $bundle exec rails runner "eval(File.read 'script/create_right.rb')"

def create_new_rights base_project, current_project, owner, collaborators
  return if base_project.nil? || current_project.nil?

  existed_rights = Right.where(project_id: base_project)
  if existed_rights.length == 0 || existed_rights.where(right_holder_id: owner.id).length == 0
    right = Right.new(project_id: base_project.id, right_holder_id: owner.id, right_holder_type: owner.class.name)
    right.save
  end

  collaborators.each do |collaborator|
    if existed_rights.length == 0 || existed_rights.where(right_holder_id: collaborator.id).length == 0
      c_right = Right.new(project_id: base_project.id, right_holder_id: collaborator.id, right_holder_type: collaborator.class.name)
      c_right.save
    end
  end

  original_project = current_project.original
  unless original_project.nil?
    create_new_rights(base_project, original_project, original_project.owner, original_project.collaborators)
  end
end

Project.all.each do |project|
  create_new_rights(project, project, project.owner, project.collaborators)
end
