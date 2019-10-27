import {MDCSnackbar}  from '@material/snackbar';

const SnackBarModule = (() => {
	const module = {};

	console.log("[SNACKBAR]: initied");

	module.show = (text) => {
		const snackbarEl = document.querySelector('.mdc-snackbar');

		if (snackbarEl) {
			const snackbar     = new MDCSnackbar(snackbarEl);
			snackbar.labelText = text;
			snackbar.open();

			setTimeout(() => {
				snackbar.destroy();
			}, 10000)
		}
	};

	return module;
})();

export {SnackBarModule};


