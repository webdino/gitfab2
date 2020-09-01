json.html (render partial: 'annotations/annotation',
                  locals: {
                    annotation: @annotation,
                    state: @state,
                    owner: @owner,
                    project: @project,
                  },
                  formats: :html)

