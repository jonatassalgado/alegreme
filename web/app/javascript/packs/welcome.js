import {MDCSnackbar} from '@material/snackbar';

document.addEventListener('DOMContentLoaded', () => {
  const snackbarEl = document.querySelector('.mdc-snackbar');

  if (snackbarEl) {
    const snackbar = new MDCSnackbar();
    snackbar.open();
  }
});
