import {Controller} from "stimulus"
import {html, render} from 'lit-html';

export default class FavoriteController extends Controller {
	static targets = ["saves", "list", "title", "date", "remove", "scrollLeft", "scrollRight", "header"];

	initialize() {
		const self = this;

		if (self.hasListTarget) {
			self.scrollLeftEvent = new CustomEvent('scrolledLeft', {'detail': {'controller': self}});
			self.scrollRightEvent = new CustomEvent('scrolledRight', {'detail': {'controller': self}});

			self.handlerScrollButtons = true;
			FavoriteController.removeRepeatedDates = true;
		}
	}

	scrollLeft(event) {
		const self = this;
		const amount = this.listTarget.offsetWidth * -1;
		this.listTarget.scrollBy(amount, 0);
		setTimeout(function () {
			self.listTarget.dispatchEvent(self.scrollLeftEvent)
		}, 400);
	}


	scrollRight(event) {
		const self = this;
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
		var containerSize = self.listTarget.offsetParent.offsetWidth;
		var scrollSizeOverflow = self.listTarget.scrollWidth;
		var scrolled = self.listTarget.scrollLeft;

		const scrollUntilX = () => containerSize + scrolled;
		const scrolledUntilEnd = () => scrollUntilX() === scrollSizeOverflow;
		const hasToScroll = () => containerSize < scrollSizeOverflow;
		const hasToScrollYet = () => scrollUntilX() < scrollSizeOverflow;
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



	static set removeRepeatedDates(value) {
		if (value === true) {
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


	set handlerScrollButtons(value) {
		const self = this;

		if (value === true) {
			self.updateScrollButtonsStatus();
			self.listTarget.addEventListener('scrolledLeft', FavoriteController.scrolledToLeft);
			self.listTarget.addEventListener('scrolledRight', FavoriteController.scrolledToRight);
		}
	}

}
