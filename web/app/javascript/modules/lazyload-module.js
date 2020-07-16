// const LazyloadModule = (function () {
// 	const module = {};
//
// 	module.init = () => {
// 		console.log("[LAZYLOAD]: started");
// 		// module.lazyloadFeed();
// 		document.addEventListener("turbolinks:load", module.lazyloadFeed);
// 	};
//
//
// 	module.lazyloadFeed = () => {
// 		console.log("[LAZYLOAD]: applyed");
//
// 		let images = [...document.querySelectorAll('.lazy-bgimage')];
//
// 		const interactSettings = {
// 			rootMargin: '0px 100px 200px 0px'
// 		};
//
// 		function onIntersection(imageEntites) {
// 			imageEntites.forEach(image => {
// 				if (image.isIntersecting) {
// 					// requestIdleCallback(() => {
// 						observer.unobserve(image.target);
// 						if (image.target.style.backgroundImage === "") {
// 							image.target.style.backgroundImage = `url(${image.target.dataset.src})`;
// 						}
// 					// }, {timeout: 250});
// 				}
// 			});
// 		}
//
// 		let observer = new IntersectionObserver(onIntersection, interactSettings);
//
// 		images.forEach(image => observer.observe(image));
// 	};
//
//
// 	window.LazyloadModule = module;
//
// 	return module;
// })();
//
// export {LazyloadModule};
