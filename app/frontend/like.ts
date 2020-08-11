import axios from "axios";
import { ActionsType, app, h, View } from "hyperapp";
import setupCSRFToken from "./lib/setupCSRFToken";

interface State {
  clickEnabled: boolean;
  liked: boolean;
  likeUrl: string;
  visible: boolean;
}
const State: State = {
  clickEnabled: true,
  liked: false,
  likeUrl: "",
  visible: true
};

interface Actions {
  initState(state: State): State;
  makeInvisible(): State;
  enable(clickEnabled: boolean): State;
  setIcon(liked: boolean): State;
  like(): State;
  unlike(): State;
}
const Actions: ActionsType<State, Actions> = {
  enable: (clickEnabled: boolean) => () => ({ clickEnabled }),
  initState: ({ liked }) => () => ({ liked }),
  like: () => async (state, actions) => {
    actions.setIcon(true);

    try {
      const response = await axios.post(state.likeUrl);
      if (!response.data.success) {
        actions.setIcon(false);
      }
    } catch {
      alertError();
      actions.setIcon(false);
    }
  },
  makeInvisible: () => () => ({ visible: false }),
  setIcon: (liked: boolean) => () => ({ liked }),
  unlike: () => async (state, actions) => {
    actions.setIcon(false);

    try {
      await axios.delete(state.likeUrl);
    } catch {
      alertError();
      actions.setIcon(true);
    }
  }
};

const alertError = () =>
  alert("An unexpected error occurred. Please try again later.");

const View: View<State, Actions> = (state, actions) =>
  h("span", {
    className: `${state.visible ? "icon" : ""} ${
      state.liked ? "icon-liked" : "icon-like"
    } ${state.clickEnabled ? "" : "disabled"}`,
    onclick: async () => {
      if (!state.clickEnabled) {
        return;
      }
      actions.enable(false);
      state.liked ? await actions.unlike() : await actions.like();
      actions.enable(true);
    },
    oncreate: () => {
      setupCSRFToken();
      axios
        .get(state.likeUrl)
        .then(response => actions.initState(response.data.like))
        .catch(actions.makeInvisible);
    }
  });

const container = document.querySelector<HTMLDivElement>("#like-component");
if (container) {
  State.likeUrl = String(container.dataset.likeUrl);
  app(State, Actions, View, container);
}
