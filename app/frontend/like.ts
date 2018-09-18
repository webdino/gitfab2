import { h, app, ActionsType, View } from "hyperapp"
import axios from "axios"
import setupCSRFToken from './lib/setupCSRFToken'

namespace Like {
  export interface State {
    visible: boolean,
    liked: boolean,
    clickEnabled: boolean,
    updateLikeUrl: string,
  }
  export const state: State = {
    visible: true,
    liked: false,
    clickEnabled: true,
    updateLikeUrl: "",
  }

  export interface Actions {
    oncreate(): State,
    onclick(): State,
    initState(state: State): State,
    makeInvisible(): State,
    enable(clickEnabled: boolean): State,
    setIcon(liked: boolean): State,
    like(): State,
    unlike(): State,
  }
  export const actions: ActionsType<State, Actions> = {
    oncreate: () => (_, actions) => {
      setupCSRFToken();
      axios.get(`${window.location.pathname}.json`)
        .then(response => actions.initState(response.data.like))
        .catch(actions.makeInvisible);
    },
    onclick: () => async (state: State, actions: Actions) => {
      if (!state.clickEnabled) { return }
      actions.enable(false);
      state.liked ? await actions.unlike() : await actions.like();
      actions.enable(true);
    },
    initState: ({ liked, updateLikeUrl }) => () => ({ liked, updateLikeUrl }),
    makeInvisible: () => () => ({ visible: false }),
    enable: (clickEnabled: boolean) => () => ({ clickEnabled }),
    setIcon: (liked: boolean) => () => ({ liked }),
    like: () => async (state, actions) => {
      actions.setIcon(true);

      try {
        const response = await axios.post(state.updateLikeUrl);
        if (!response.data.success) { actions.setIcon(false) }
      } catch {
        alertError();
        actions.setIcon(false);
      }
    },
    unlike: () => async (state, actions) => {
      actions.setIcon(false);

      try {
        await axios.delete(state.updateLikeUrl)
      } catch {
        alertError();
        actions.setIcon(true);
      }
    },
  }

  const alertError = () => alert("An unexpected error occurred. Please try again later.");
}

const view: View<Like.State, Like.Actions> = (state: Like.State, actions: Like.Actions) => (
  h("span", {
    oncreate: actions.oncreate,
    onclick: actions.onclick,
    className: `${state.visible ? 'icon' : ''} ${state.liked ? 'icon-liked' : 'icon-like'} ${state.clickEnabled ? '' : 'disabled'}`
  })
)

app(Like.state, Like.actions, view, document.querySelector("#like-component"))
