const LazyloadModule = (function () {
	const module = {};

	module.init = () => {
		module.lazyloadFeed();
		console.log("[LAZYLOAD]: started");
	};


	module.lazyloadFeed = () => {

		let images = [...document.querySelectorAll('.lazy-bgimage')];

		const interactSettings = {
			rootMargin: '0px 0px 200px 0px'
		};

		function onIntersection(imageEntites) {
			imageEntites.forEach(image => {
				if (image.isIntersecting) {
					requestIdleCallback(() => {
						observer.unobserve(image.target);
						if (image.target.style.backgroundImage === "") {
							image.target.style.backgroundImage = `url(${image.target.dataset.src})`;
						}
					});
				}
			});
		}

		let observer = new IntersectionObserver(onIntersection, interactSettings);

		images.forEach(image => observer.observe(image));
	};

	document.addEventListener("turbolinks:load", module.lazyloadFeed, {once: true})
	document.addEventListener("turbolinks:render", module.lazyloadFeed)

	window.LazyloadModule = module;

	return module;
})();

export {LazyloadModule};
