import { h, app, ActionsType, View } from "hyperapp"

namespace Counter {
  export interface State {
    count: number
  }

  export interface Actions {
    down(): State
    up(): State
  }

  export const state: State = {
    count: 0
  }

  export const actions: ActionsType<State, Actions> = {
    down: () => (state: State) => ({ count: state.count - 1 }),
    up: () => (state: State) => ({ count: state.count + 1 })
  }
}

const view: View<Counter.State, Counter.Actions> = (state: Counter.State, actions: Counter.Actions) => (
  <div>
    <h1>{state.count}</h1>
    <button onclick={actions.down}>-</button>
    <button onclick={actions.up}>+</button>
  </div>
)

app(Counter.state, Counter.actions, view, document.body)
