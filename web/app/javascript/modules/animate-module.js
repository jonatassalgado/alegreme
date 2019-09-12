const AnimateModule = (function () {
	const module = {};

	module.init = () => {
		module.animatePage();
		console.log("[ANIMATE]: started");
	};

	module.animatePage = () => {
				requestAnimationFrame(() => {
					const page = document.querySelector(".me-page");
					if (page) {
						page.classList.remove("is-animated");
					}
				})
		document.addEventListener("turbolinks:before-cache", () => {
			const page = document.querySelector(".me-page");
			if (page) {
				page.classList.add("is-animated");
			}
		}, false);
	};

	module.animateBackbutton = () => {
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

	document.addEventListener("turbolinks:load", module.animatePage, {once: true})
	document.addEventListener("turbolinks:render", module.animatePage)

	window.AnimateModule = module;

	return module;
})();

export {AnimateModule};


