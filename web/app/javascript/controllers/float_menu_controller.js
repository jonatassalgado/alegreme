import {Controller}      from "stimulus";
import * as MobileDetect from "mobile-detect";

export default class Float_menu_controller extends Controller {
	static targets = [
		"menu",
		"item"
	];

	initialize() {
		this.md                    = new MobileDetect(window.navigator.userAgent);
		const observableSectionEls = document.querySelectorAll('[data-observable="float-menu.section"]');

		if (this.hasMenuTarget && observableSectionEls !== undefined) {
			const threshold = 0.60;

			this.observer = new IntersectionObserver((entries, observer) => {
					entries.forEach((entry) => {
						const collectionEl = document.querySelector(`[data-collection-identifier="${entry.target.id}"]`);

						if (collectionEl) {
							if (entry.isIntersecting) {
								collectionEl.classList.add('is-active')
							} else {
								collectionEl.classList.remove('is-active')
							}
						}
					})
				},
				{
					threshold: [threshold]
				}
			);

			observableSectionEls.forEach((section) => {
				this.observer.observe(section);
				requestAnimationFrame(() => {
					const item = document.querySelector(`[data-collection-identifier="${section.id}"]`);

					if (item) {
						item.style.display = 'flex';
						item.style.opacity = 1;
					}
				});
			});
		}
	};

	scrollTo(event) {
		const identifier                              = event.target.closest('.me-float-menu__item').dataset.collectionIdentifier;
		const sectionEl                               = document.getElementById(identifier);
		document.documentElement.style.scrollBehavior = "smooth";

		if (this.md.mobile()) {
			window.scrollTo(0, sectionEl.offsetTop + 50);
		} else {
			window.scrollTo(0, sectionEl.offsetTop + 20);
		}

		document.documentElement.style.scrollBehavior = ""
	}

}
