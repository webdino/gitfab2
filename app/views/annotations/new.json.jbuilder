json.html (
  render 'components/card_form', model: @annotation,
    url: project_recipe_state_annotations_path(@owner, @project, @state)
)
