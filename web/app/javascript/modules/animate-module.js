const AnimateModule = (function () {
	const module = {};

	module.init = () => {
		module.animatePage();
		console.log("[ANIMATE]: started");
	};

	module.animatePage = () => {
		["DOMContentLoaded", "turbolinks:load"].forEach((eventName) => {
			document.addEventListener(eventName, () => {
				requestAnimationFrame(() => {
					const page = document.querySelector(".me-page");
					if (page) {
						page.classList.remove("is-animated");
					}
				})
			}, false);
		});
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

	window.AnimateModule = module;

	return module;
})();

export {AnimateModule};


