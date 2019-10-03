import {MDCSnackbar} from '@material/snackbar';
import pwaInstallPrompt from "pwa-install-prompt";

document.addEventListener('DOMContentLoaded', () => {
  window.prompt = new pwaInstallPrompt(".pwa-install-prompt__container", {
      active_class: "is-active",
      closer: ".pwa-install-prompt__overlay",
      condition: false,
      expires: 180,
      show_after: 90,
      on: {
          beforeOpen: function () {
              // console.log("before open!");
          },
          afterOpen: function () {
              // console.log("after open!");
          },
          beforeClose: function () {
              // console.log("before close!");
          },
          afterClose: function () {
              // console.log("after close!");
          },
      }
  });


  const snackbarEl = document.querySelector('.mdc-snackbar');

  if (snackbarEl) {
    const snackbar = new MDCSnackbar();
    snackbar.open();
  }
});
