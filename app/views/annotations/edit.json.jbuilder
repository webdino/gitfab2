json.html (
  render 'components/card_form', model: @annotation,
    url: project_recipe_state_annotation_path(@owner, @project, @state, @annotation)
)
