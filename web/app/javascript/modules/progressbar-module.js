import Turbolinks from "turbolinks"

const ProgressBarModule = (() => {
	const module    = {};
	const progressBar = new Turbolinks.ProgressBar();

	console.log("[PROGRESSBAR]: initied");

	module.show = () => {
		progressBar.setValue(0);
		progressBar.show();
	};

	module.hide = () => {
		progressBar.setValue(1);
		setTimeout(() => {
			progressBar.hide();
		}, 100);
	};

	return module;
})();

export {ProgressBarModule};


