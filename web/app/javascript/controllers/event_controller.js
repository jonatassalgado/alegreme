import {Controller}          from "stimulus";
import {MDCMenu}             from "@material/menu";
import {MDCRipple}           from "@material/ripple";
import {MDCIconButtonToggle} from "@material/icon-button";
import * as MobileDetect     from "mobile-detect";
import {ProgressBarModule}   from "../modules/progressbar-module";

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
		this.adjustForDevice    = this.md.mobile();
		this.activeInteractions = true;
		this.pubsub             = {};

		this.pubsub.savesUpdated = PubSubModule.on(`saves.updated`, (data) => {
			if (data.detail.eventId == this.identifier) {
				this.likeStatus = data.detail.currentEventFavorited;
				this.updateLikeButtonStyle(data.detail.eventId);
			}
		});

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
			this.pubsub.savesUpdated();
			this.pubsub.sectionUpdated();
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
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

	like() {
		PubSubModule.emit('event.like');

		fetch(`/api/taste/events/${this.identifier}/${this.isFavorited}`, {
			method     : 'post',
			headers    : {
				'X-Requested-With': 'XMLHttpRequest',
				'Content-type'    : 'text/javascript; charset=UTF-8',
				'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
			},
			credentials: 'same-origin'
		})
			.then(
				response => {
					response.text().then(data => {
						eval(data);
						CacheModule.clearCache(['feed-page', 'events-page'], {
							event: {
								identifier: this.identifier
							}
						});
					});
				}
			)
			.catch(err => {
				console.log('Fetch Error :-S', err);
			});

	}

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

	get isFavorited() {
		if (this.data.get("favorited") === "true") {
			return "unsave";
		} else {
			return "save";
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

	set likeStatus(status) {
		this.data.set("favorited", status);
	}

	set likeCount(value) {
		const likeElementsCounts = document.querySelectorAll(
			`[data-event-identifier="${value.event_id}"] .me-like-count`
		);
		likeElementsCounts.forEach(count => {
			count.textContent = value.event_likes_count;
		});
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

	set adjustForDevice(isMobile) {
		const isFavorited = this.data.get("favorited") === "false";
		const isSingle    = this.data.get("modifier") === "single";

		if (isMobile) {
		} else {
			if (isFavorited && !isSingle) {
				this.likeButtonTarget.style.display = "none";
			}
		}
	}
}
