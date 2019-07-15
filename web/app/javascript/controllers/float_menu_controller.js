import {Controller} from "stimulus";

export default class Float_menu_controller extends Controller {
	static targets = [
		"menu",
		"item"
	];

	initialize() {
		this.observer = new IntersectionObserver((entries, observer) => {
				entries.forEach((entry) => {
					if (entry.isIntersecting) {
						document.querySelector(`[data-collection-identifier="${entry.target.id}"]`).classList.add('is-active')
					} else {
						document.querySelector(`[data-collection-identifier="${entry.target.id}"]`).classList.remove('is-active')
					}
				})
			},
			{
				threshold: [0.85]
			}
		);

		document.querySelectorAll('[data-observable="float-menu.section"]').forEach((section) => {
			this.observer.observe(section);

			requestAnimationFrame(() => {
				const item         = document.querySelector(`[data-collection-identifier="${section.id}"]`);
				item.style.display = 'flex';
				item.style.opacity = 1;

			});
		});


	};

	scrollTo(event) {
		const identifier = event.target.closest('.me-float-menu__item').dataset.collectionIdentifier;
		const sectionEl  = document.getElementById(identifier);

		window.scrollTo(0, sectionEl.offsetTop);
	}

}
