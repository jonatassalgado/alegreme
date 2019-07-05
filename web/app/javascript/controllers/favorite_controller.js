import {Controller} from "stimulus"
import Flipping     from "flipping"

export default class FavoriteController extends Controller {
	static targets = ["saves", "list", "title", "date", "remove", "scrollLeft", "scrollRight", "header"];

	initialize() {
		const self = this;

		self.flipping = new Flipping({
			attribute: 'data-saves-flip-key'
		});

		if (self.hasListTarget) {
			self.scrollLeftEvent  = new CustomEvent('scrolledLeft', {'detail': {'controller': self}});
			self.scrollRightEvent = new CustomEvent('scrolledRight', {'detail': {'controller': self}});

			self.updateScrollButtonsStatus();
			self.removeRepeatedDates();
		}

		self.subscription = postal.subscribe({
			channel : `event`,
			topic   : `event.like`,
			callback: function (data, envelope) {
				self.flipping.read();
			}
		});

		self.subscription = postal.subscribe({
			channel : `saves`,
			topic   : `saves.updated`,
			callback: function (data, envelope) {
				console.log(self.flipping);

				const flipPromise = new Promise((resolve, reject) => {
					self.flipping.flip();

					const flipped = Object.keys(self.flipping.states).forEach(function (key) {
						const state = self.flipping.states[key];

						if (state.type === 'MOVE' && state.delta) {
							state.element.style.transition = '';
							state.element.style.transform  = `translateY(${state.delta.top}px) translateX(${state.delta.left}px)`;
						}
						if (state.type === 'ENTER') {
							state.element.style.opacity   = 0;
							state.element.style.transform = `scale(0.85)`;
						}

						requestAnimationFrame(function () {

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
					self.updateScrollButtonsStatus();
					self.removeRepeatedDates();
				})


			}
		});

		if (self.hasListTarget) {
			self.listTarget.addEventListener('scrolledLeft', FavoriteController.scrolledToLeft);
			self.listTarget.addEventListener('scrolledRight', FavoriteController.scrolledToRight);
		}

		document.addEventListener("turbolinks:before-cache", () => {
			self.subscription.unsubscribe();
		});

	}

	scrollLeft(event) {
		const self   = this;
		const amount = this.listTarget.offsetWidth * -1;
		this.listTarget.scrollBy(amount, 0);
		setTimeout(function () {
			self.listTarget.dispatchEvent(self.scrollLeftEvent)
		}, 400);
	}


	scrollRight(event) {
		const self   = this;
		const amount = self.listTarget.offsetWidth;
		self.listTarget.scrollBy(amount, 0);
		setTimeout(function () {
			self.listTarget.dispatchEvent(self.scrollRightEvent)
		}, 400);
	}

	static scrolledToLeft(event) {
		event.detail.controller.updateScrollButtonsStatus()
	}

	static scrolledToRight(event) {
		event.detail.controller.updateScrollButtonsStatus()
	}

	updateScrollButtonsStatus() {
		let self = this;

		if (!self.hasListTarget) {
			return false;
		}

		var containerSize      = self.listTarget.offsetParent.offsetWidth;
		var scrollSizeOverflow = self.listTarget.scrollWidth;
		var scrolled           = self.listTarget.scrollLeft;

		const scrollUntilX         = () => containerSize + scrolled;
		const scrolledUntilEnd     = () => scrollUntilX() === scrollSizeOverflow;
		const hasToScroll          = () => containerSize < scrollSizeOverflow;
		const hasToScrollYet       = () => scrollUntilX() < scrollSizeOverflow;
		const scrollInZeroPosition = () => scrolled === 0;

		function switchLeftButton(turnOn = true) {
			if (turnOn) {
				self.scrollLeftTarget.classList.remove('me-icon--off');
				self.listTarget.classList.remove('me-favorite__list--at-end');
				self.listTarget.classList.add('me-favorite__list--at-initital');
			} else {
				self.scrollLeftTarget.classList.add('me-icon--off');
				self.listTarget.classList.remove('me-favorite__list--at-initital');
			}
		}

		function switchRightButton(turnOn = true) {
			if (turnOn) {
				self.scrollRightTarget.classList.remove('me-icon--off');
				self.listTarget.classList.add('me-favorite__list--at-end');
				self.listTarget.classList.remove('me-favorite__list--at-initital');
			} else {
				self.scrollRightTarget.classList.add('me-icon--off');
				self.listTarget.classList.remove('me-favorite__list--at-end');
			}

		}

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

	}


	removeRepeatedDates() {
		const self = this;

		if (self.hasListTarget) {
			const dates = document.querySelectorAll('.me-favorite .me-card__date');
			var lastDay = dates[0].innerText;
			for (var i = 0; i < dates.length - 1; i++) {
				if (lastDay !== dates[i + 1].innerText) {
					lastDay = dates[i].innerText;
				}
				if (lastDay === dates[i + 1].innerText) {
					dates[i + 1].innerHTML = '';
				}
			}
		}
	}


}
