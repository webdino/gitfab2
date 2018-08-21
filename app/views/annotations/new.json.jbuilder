json.html (
  render 'components/card_form', model: @annotation,
    url: project_state_annotations_path(@owner, @project, @state)
)
