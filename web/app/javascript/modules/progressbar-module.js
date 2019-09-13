import Turbolinks from "turbolinks"

const ProgressBarModule = (() => {
	const module      = {};
	const progressBar = new Turbolinks.ProgressBar();

	console.log("[PROGRESSBAR]: initied");

	module.show = () => {
		progressBar.setValue(0);
		progressBar.show();
	};

	module.hide = () => {
		setTimeout(() => {
			requestIdleCallback(() => {
				progressBar.setValue(1);
				setTimeout(() => {
					progressBar.hide();
				}, 100);
			}, {timeout: 250});
		}, 250);
	};

	return module;
})();

export {ProgressBarModule};


