// ref: https://github.com/rails/webpacker/issues/1015#issuecomment-386241735

import axios from "axios";

export default function() {
  const tokenDom = document.querySelector("meta[name=csrf-token]");
  if (tokenDom) {
    const csrfToken = tokenDom.getAttribute("content");
    axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;
  }
}
