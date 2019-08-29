const AnimateModule = (function () {
	const module = {};

	module.init = () => {
		module.animateFeeds();
		module.animateEventsShow();
		console.log("[ANIMATE]: started");
	};

	module.animateFeeds = () => {
		["DOMContentLoaded", "turbolinks:load"].forEach((eventName) => {
			document.addEventListener(eventName, () => {
				const page = document.querySelector(".me-page--feed-section");
				requestAnimationFrame(() => {
					if (page) {
						page.classList.remove("is-animated");
					}
				})
			}, false);
		});
		["turbolinks:before-cache"].forEach((eventName) => {
			document.addEventListener(eventName, () => {
				const page = document.querySelector(".me-page");
				if (page) {
					page.classList.add("is-animated");
				}
			}, false);
		});
	};

	module.animateEventsShow = () => {
		["DOMContentLoaded", "turbolinks:load"].forEach((eventName) => {
			document.addEventListener(eventName, () => {
				const page = document.querySelector(".me-page--events-section");
				requestAnimationFrame(() => {
					if (page) {
						page.classList.remove("is-animated");
					}
				})
			}, false);
		});
		["turbolinks:before-cache"].forEach((eventName) => {
			document.addEventListener(eventName, () => {
				const page = document.querySelector(".me-page--events-section");
				if (page) {
					page.classList.add("is-animated");
				}
			}, false);
		});
	};

	window.AnimateModule = module;

	return module;
})();

export {AnimateModule};


