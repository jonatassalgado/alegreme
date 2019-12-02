const AnimateModule = (function () {
	const module = {};

	module.init = () => {
		document.addEventListener("turbolinks:load", module.animatePage);
		console.log("[ANIMATE]: started");
	};

	module.animatePage = () => {
		console.log("[ANIMATE]: animate page");
		requestAnimationFrame(() => {
			const page = document.querySelector(".me-page");
			if (page) {
				page.classList.remove("is-animated");
			}
		});
		document.addEventListener("turbolinks:before-cache", () => {
			const page = document.querySelector(".me-page");
			if (page) {
				page.classList.add("is-animated");
			}
		}, false);
	};

	module.animateBackbutton = () => {
		console.log("[ANIMATE]: backbutton");
		requestAnimationFrame(() => {
			const page = document.querySelector(".me-page");
			if (page) {
				page.classList.add("is-animated");
			}
		});

		setTimeout(() => {
			window.history.back();
		}, 25)
	};

	window.AnimateModule = module;

	return module;
})();

export {AnimateModule};
