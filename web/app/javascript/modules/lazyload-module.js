const LazyloadModule = (function () {
	const module = {};

	module.init = () => {
		module.lazyloadFeed();
		console.log("[LAZYLOAD]: started");
	};


	module.lazyloadFeed = () => {
		// ["DOMContentLoaded", "turbolinks:load"].forEach((eventName) => {
		// 	document.addEventListener(eventName, () => {
				let images = [...document.querySelectorAll('.lazy-bgimage')]

				const interactSettings = {
					rootMargin: '0px 0px 200px 0px'
				};

				function onIntersection(imageEntites) {
					imageEntites.forEach(image => {
						if (image.isIntersecting) {
							observer.unobserve(image.target);
							image.target.style.backgroundImage = `url(${image.target.dataset.src})`;
							image.target.classList.remove('hidden');
							// document.addEventListener("turbolinks:before-cache", () => {
							// 	image.target.style.backgroundImage = `url(${image.target.dataset.src})`;
							// 	image.target.style.backgroundImage = `url(${image.target.dataset.src})`;
							// 	image.target.classList.remove('hidden');
							// }, false);
						}
					})

				}
				let observer = new IntersectionObserver(onIntersection, interactSettings);

				images.forEach(image => observer.observe(image));
			// });
		// });
	};

	window.LazyloadModule = module;

	return module;
})();

export {LazyloadModule};
