import {Controller}     from "stimulus"
import Flipping         from "flipping"
import {LazyloadModule} from "../modules/lazyload-module";

export default class SavesController extends Controller {
	static targets = ["saves", "list", "title", "date", "remove", "scrollLeft", "scrollRight", "header"];

	initialize() {
		this.flipping = new Flipping({
			attribute: 'data-saves-flip-key'
		});

		if (this.hasListTarget) {
			this.scrollLeftEvent  = new CustomEvent('scrolledLeft', {'detail': {'controller': this}});
			this.scrollRightEvent = new CustomEvent('scrolledRight', {'detail': {'controller': this}});

			this.updateScrollButtonsStatus();
			this.removeRepeatedDates();
		}

		this.subscription = postal.subscribe({
			channel : `event`,
			topic   : `event.like`,
			callback: (data, envelope) => {
				this.flipping.read();
			}
		});

		this.subscription = postal.subscribe({
			channel : `saves`,
			topic   : `saves.updated`,
			callback: (data, envelope) => {
				LazyloadModule.init();

				const flipPromise = new Promise((resolve, reject) => {
					this.flipping.flip();

					const flipped = Object.keys(this.flipping.states).forEach((key) => {
						const state = this.flipping.states[key];

						if (state.type === 'MOVE' && state.delta) {
							state.element.style.transition = '';
							state.element.style.transform  = `translateY(${state.delta.top}px) translateX(${state.delta.left}px)`;
						}
						if (state.type === 'ENTER') {
							state.element.style.opacity   = 0;
							state.element.style.transform = `scale(0.85)`;
						}

						requestAnimationFrame(() => {

							if (state.type === 'MOVE' && state.delta) {
								state.element.style.transition = 'transform 0.6s cubic-bezier(.54,.01,.45,.99)';
								state.element.style.transform  = '';
								state.element.style.opacity    = 1;
							}
							if (state.type === 'ENTER') {
								state.element.style.transition = 'transform 0.4s cubic-bezier(.54,.01,.45,.99) 0.350s, opacity 0.4s cubic-bezier(0,.16,.45,.99) 0.350s';
								state.element.style.transform  = '';
								state.element.style.opacity    = 1;
							}

						});
					});

					resolve(flipped)
				});

				flipPromise.then(() => {
					this.updateScrollButtonsStatus();
					this.removeRepeatedDates();
				})


			}
		});

		if (this.hasListTarget) {
			this.flipping.read();
			this.listTarget.addEventListener('scrolledLeft', SavesController.scrolledToLeft);
			this.listTarget.addEventListener('scrolledRight', SavesController.scrolledToRight);
		}

		this.destroy = () => {
			this.subscription.unsubscribe();
			if (this.hasListTarget) {
				delete this.scrollLeftEvent;
				delete this.scrollRightEvent;
			}
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	scrollLeft(event) {
		const amount = this.listTarget.offsetWidth * -1;
		this.listTarget.scrollBy(amount, 0);
		setTimeout(() => {
			this.listTarget.dispatchEvent(this.scrollLeftEvent)
		}, 350);
	}


	scrollRight(event) {
		const amount = this.listTarget.offsetWidth;
		this.listTarget.scrollBy(amount, 0);
		setTimeout(() => {
			this.listTarget.dispatchEvent(this.scrollRightEvent)
		}, 350);
	}

	static scrolledToLeft(event) {
		event.detail.controller.updateScrollButtonsStatus()
	}

	static scrolledToRight(event) {
		event.detail.controller.updateScrollButtonsStatus()
	}

	updateScrollButtonsStatus() {
		if (!this.hasListTarget) {
			return false;
		}

		requestAnimationFrame(() => {
			var containerSize      = this.listTarget.offsetParent.offsetWidth;
			var scrollSizeOverflow = this.listTarget.scrollWidth;
			var scrolled           = this.listTarget.scrollLeft;

			const scrollUntilX         = () => containerSize + scrolled;
			const scrolledUntilEnd     = () => scrollUntilX() === scrollSizeOverflow;
			const hasToScroll          = () => containerSize < scrollSizeOverflow;
			const hasToScrollYet       = () => scrollUntilX() < scrollSizeOverflow;
			const scrollInZeroPosition = () => scrolled === 0;

			const switchLeftButton = (turnOn = true) => {
				if (turnOn) {
					this.scrollLeftTarget.classList.remove('me-icon--off');
					this.listTarget.classList.remove('me-saves__list--at-end');
					this.listTarget.classList.add('me-saves__list--at-initital');
				} else {
					this.scrollLeftTarget.classList.add('me-icon--off');
					this.listTarget.classList.remove('me-saves__list--at-initital');
				}
			};

			const switchRightButton = (turnOn = true) => {
				if (turnOn) {
					this.scrollRightTarget.classList.remove('me-icon--off');
					this.listTarget.classList.add('me-saves__list--at-end');
					this.listTarget.classList.remove('me-saves__list--at-initital');
				} else {
					this.scrollRightTarget.classList.add('me-icon--off');
					this.listTarget.classList.remove('me-saves__list--at-end');
				}

			};

			if (scrollInZeroPosition() && scrolledUntilEnd()) {
				switchLeftButton(false);
				switchRightButton(false)
			} else if (scrolledUntilEnd() && hasToScroll()) {
				switchLeftButton();
				switchRightButton(false)
			} else if (scrollInZeroPosition() && hasToScrollYet()) {
				switchRightButton();
				switchLeftButton(false)
			} else if (hasToScrollYet() && !scrolledUntilEnd() && !scrollInZeroPosition()) {
				switchLeftButton();
				switchRightButton()
			}
		});
	}


	removeRepeatedDates() {
		if (this.hasListTarget) {
			requestIdleCallback(() => {
				const dates = document.querySelectorAll('.me-saves .me-card__date');
				var lastDay = dates[0].innerText;
				for (var i = 0; i < dates.length - 1; i++) {
					if (lastDay !== dates[i + 1].innerText) {
						lastDay = dates[i].innerText;
					}
					if (lastDay === dates[i + 1].innerText) {
						dates[i + 1].innerHTML = '';
					}
				}
			});
		}
	}


}
