const AnimateModule = (function () {
	const module = {};
	const isPwa  = (window.matchMedia('(display-mode: standalone)').matches) || (window.navigator.standalone) || document.referrer.includes('android-app://');

	module.init = () => {
		document.addEventListener("turbolinks:load", module.animateOpenPage);
		console.log("[ANIMATE]: started");
	};

	module.animateOpenPage = () => {
		const page = document.querySelector(".me-page.is-animated");

		if (isPwa && page) {
			console.log("[ANIMATE]: animate page");
			page.style.opacity   = 0;
			page.style.transform = "translate(0, 10vh) scale(0.95)"

			requestAnimationFrame(() => {
				if (page) {
					page.style.opacity   = 1;
					page.style.transform = ""
				}
			});
			document.addEventListener("turbolinks:before-cache", () => {
				if (page) {
					page.style.opacity   = 0;
					page.style.transform = "translate(0, 10vh) scale(0.95)"
				}
			}, false);
		}
	};

	module.animatePageHide = () => {
		const page = document.querySelector(".me-page.is-animated");

		if (isPwa && page) {
			console.log("[ANIMATE]: page hide");
			page.style.opacity   = 1;
			page.style.transform = ""

			requestAnimationFrame(() => {
				if (page) {
					page.style.opacity   = 0;
					page.style.transform = "scale(0.95)"
				}
			});
		}
	};

	module.animateBackbutton = () => {
		const page = document.querySelector(".me-page.is-animated");

		if (isPwa && page) {
			console.log("[ANIMATE]: backbutton");

			requestAnimationFrame(() => {
				if (page) {
					page.style.opacity = 0;
					page.style.transform = "translate(0, 10vh) scale(0.95)"
				}
			});

			setTimeout(() => {
				window.history.back();
			}, 25)
		}
	};

	window.AnimateModule = module;

	return module;
})();

export {AnimateModule};
