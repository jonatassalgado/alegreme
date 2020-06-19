import {Controller}          from "stimulus";
import {MDCMenu}             from "@material/menu";
import {MDCRipple}           from "@material/ripple";
import {MDCIconButtonToggle} from "@material/icon-button";
import * as MobileDetect     from "mobile-detect";
import {ProgressBarModule}   from "../modules/progressbar-module";
import {AnimateModule}       from "../modules/animate-module";

export default class EventController extends Controller {
	static targets = [
		"event",
		"overlay",
		"name",
		"place",
		"date",
		"like",
		"likeButton",
		"likeCount",
		"moreButton",
		"menu"
	];

	initialize() {
		this.itemsPerRow        = 4;
		this.md                 = new MobileDetect(window.navigator.userAgent);
		this.activeInteractions = true;
		this.pubsub             = {};

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.sectionIdentifier}.updated`, (data) => {
			if (data.params.similar == this.identifier) {
				this.isSimilarOpen = true;

				ProgressBarModule.hide();
				setTimeout(() => {
					requestIdleCallback(() => {
						const eventEl = document.getElementById(`similar-to-${data.params.similar}`);

						if (eventEl === null) return;

						document.documentElement.style.scrollBehavior = "smooth";
						if(this.md.mobile()) {
							window.scrollTo(0, eventEl.offsetTop - 150);
						} else {
							window.scrollTo(0, eventEl.offsetTop - 225);
						}
						document.documentElement.style.scrollBehavior = "";
					}, {timeout: 250})
				}, 500);
			}
		});

		this.destroy = () => {
			this.activeInteractions = false;
			this.pubsub.sectionUpdated();
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	handleEventClick() {
		AnimateModule.animatePageHide();
	}

	handlePlaceClick() {
		AnimateModule.animatePageHide();
	}

	showEventDetails() {
		if (this.md.mobile()) {
		} else {
			if (this.data.get("favorited") === "false" && this.hasLikeButtonTarget) {
				this.likeButtonTarget.style.display = "inline";
			}

			this.eventTarget.addEventListener("mouseout", () => {
				if (this.data.get("favorited") === "false" && this.hasLikeButtonTarget) {
					this.likeButtonTarget.style.display = "none";
				}
			});
		}
	};

	showSimilar() {
		this.isSimilarLoading = true;

		ProgressBarModule.show();

		PubSubModule.emit(`${this.sectionIdentifier}.create`,
			{
				similar     : this.identifier,
				insert_after: this.insertAfter,
				limit       : this.sectionController.actualEventsInCollection,
				id          : this.eventTarget.id
			}
		);
	};

	openMenu() {
		const mdcMenu = new MDCMenu(this.menuTarget);
		mdcMenu.open  = !mdcMenu.open;
	};


	updateLikeButtonStyle(eventId) {
		const active = this.data.get('favorited');

		if (this.hasLikeButtonTarget) {
			if (active === 'true') {
				this.likeButtonTarget.style.display = 'inline';
				this.likeButtonTarget.classList.add('mdc-icon-button--on')
			} else {
				this.likeButtonTarget.classList.remove('mdc-icon-button--on');
				if (eventId != this.identifier) {
					this.likeButtonTarget.style.display = 'none';
				}
			}
		}

	};

	readMore() {
		this.data.set('description-open', true);
	}

	get insertAfter() {
		const order = parseInt(this.eventTarget.parentElement.style.order);

		if (this.md.mobile()) {
			return order;
		} else {
			return (Math.ceil(order / this.itemsPerRow)) * this.itemsPerRow
		}
	}

	get isSimilarOpen() {
		return this.data.get("similarOpen");
	}

	set isSimilarOpen(value) {
		this.data.set("similar-open", value);
	}

	set isSimilarLoading(value) {
		this.data.set("similar-loading", value);
	}

	get identifier() {
		return this.data.get("identifier");
	}

	get favoriteController() {
		return this.application.controllers.find(controller => controller.context.identifier === 'saves');
	}

	get sectionController() {
		const collectionEl = this.eventTarget.closest('[data-controller="section"]');
		return this.application.getControllerForElementAndIdentifier(collectionEl, 'section');
	}

	get sectionIdentifier() {
		const section = this.eventTarget.closest('[data-controller="section"]');

		if (this.hasEventTarget && section) {
			return section.id;
		}
	}

	set activeInteractions(value) {
		if (value) {
			if (this.hasOverlayTarget && !this.overlayRipple) {
				this.overlayRipple = new MDCRipple(this.overlayTarget);
			}
			if (this.hasLikeButtonTarget) {
				this.toggleLikeButton = new MDCIconButtonToggle(
					this.likeButtonTarget
				);
			}
		} else {
			if (this.overlayRipple) {
				this.overlayRipple.destroy();
			}
			if (this.toggleLikeButton) {
				this.toggleLikeButton.destroy();
			}
		}
	}

}
