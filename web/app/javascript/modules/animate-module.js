import * as MobileDetect from "mobile-detect";

const AnimateModule = (function () {
	const module = {};
	const md     =  new MobileDetect(window.navigator.userAgent);
	const isPwa  = (window.matchMedia('(display-mode: standalone)').matches) || (window.navigator.standalone) || document.referrer.includes('android-app://');

	module.init = () => {
		document.addEventListener("turbolinks:load", module.animateOpenPage);
		console.log("[ANIMATE]: started");
	};

	module.animateOpenPage = () => {
		const page = document.querySelector(".me-page.is-animated");

		if (md.mobile()) {
			console.log("[ANIMATE]: animate page");

			if (page) {
				page.style.opacity   = 0;
				page.style.transform = "translate(0, 10vh) scale(0.95)"

				requestAnimationFrame(() => {
						page.style.opacity   = 1;
						page.style.transform = ""
				});
			}
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

		if (md.mobile()) {
			console.log("[ANIMATE]: page hide");

			if (page) {
				page.style.opacity   = 1;
				// page.style.transform = ""

				requestAnimationFrame(() => {
					page.style.opacity   = 0;
					// page.style.transform = "scale(0.95)"
				});
			}
		}
	};

	module.animateBackbutton = () => {
		const page = document.querySelector(".me-page.is-animated");

		if (md.mobile()) {
			console.log("[ANIMATE]: backbutton");

			if (page) {
				requestAnimationFrame(() => {
						page.style.opacity = 0;
						page.style.transform = "translate(0, 10vh) scale(0.95)"
				});
			}
		}

		setTimeout(() => {
			window.history.back();
		}, 25)
	};

	window.AnimateModule = module;

	return module;
})();

export {AnimateModule};
