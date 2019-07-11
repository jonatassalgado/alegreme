import {Controller}      from "stimulus";
import {MDCMenu}         from "@material/menu";
import {MDCRipple}       from "@material/ripple";
import {CacheSystem}     from "modules/cache-system";
import * as MobileDetect from "mobile-detect";
import * as mdc          from "material-components-web";

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

	initialize = () => {
		this.md                 = new MobileDetect(window.navigator.userAgent);
		this.adjustForDevice    = this.md.mobile();
		this.subscriptions      = {};
		this.activeInteractions = true;


		this.subscriptions.savesUpdated = postal.subscribe({
			channel : `saves`,
			topic   : `saves.updated`,
			callback: (data, envelope) => {
				if (data.detail.eventId == this.identifier) {
					this.likeStatus = data.detail.currentEventFavorited;
					this.updateLikeButtonStyle(data.detail.eventId);
				}
			}
		});

		this.subscriptions.filterUpdated = postal.subscribe(
			{
				channel : `${this.sectionIdentifier}`,
				topic   : `${this.sectionIdentifier}.updated`,
				callback: (data, envelope) => {
					if (data.params.similar == this.identifier) {
						this.isSimilarOpen = true;
					}
				}
			});

		document.addEventListener("turbolinks:before-cache", () => {
			this.activeInteractions = false;

			this.subscriptions.filterUpdated.unsubscribe();
			this.subscriptions.savesUpdated.unsubscribe();
		});
	};

	showEventDetails = () => {
		if (this.md.mobile()) {
		} else {
			if (this.data.get("favorited") === "false") {
				this.likeButtonTarget.style.display = "inline";
			}

			this.eventTarget.addEventListener("mouseout", () => {
				if (this.data.get("favorited") === "false") {
					this.likeButtonTarget.style.display = "none";
				}
			});
		}
	};

	showSimilar = () => {
		postal.publish({
			channel: `${this.sectionIdentifier}`,
			topic  : `${this.sectionIdentifier}.create`,
			data   : {
				similar     : this.identifier,
				insert_after: this.insertAfter
			}
		});
	};

	openMenu = () => {
		const mdcMenu = new MDCMenu(this.menuTarget);
		mdcMenu.open  = !mdcMenu.open;
	};


	updateLikeButtonStyle = (eventId) => {
		const active = this.data.get('favorited');

		if (active === 'true') {
			this.likeButtonTarget.style.display = 'inline';
			this.likeButtonTarget.classList.add('mdc-icon-button--on')
		} else {
			this.likeButtonTarget.classList.remove('mdc-icon-button--on');
			if (eventId != this.identifier) {
				this.likeButtonTarget.style.display = 'none';
			}
		}
	};

	like() {
		postal.publish({
			channel: "event",
			topic  : "event.like",
			data   : {}
		});

		fetch(`/events/${this.identifier}/favorite`, {
			method     : this.isFavorited,
			headers    : {
				'X-Requested-With': 'XMLHttpRequest',
				'Content-type'    : 'text/javascript; charset=UTF-8',
				'X-CSRF-Token'    : Rails.csrfToken()
			},
			credentials: 'same-origin'
		})
			.then(
				response => {
					response.text().then(data => {
						eval(data);
					});
				}
			)
			.catch(err => {
				console.log('Fetch Error :-S', err);
			});

	}

	get insertAfter() {
		const order = parseInt(this.eventTarget.parentElement.style.order);

		if (order <= 3) {
			return 3
		} else {
			return 7
		}
	}

	get isFavorited() {
		if (this.data.get("favorited") === "true") {
			return "delete";
		} else {
			return "post";
		}
	}

	get isSimilarOpen() {
		return this.data.get("similarOpen");
	}

	set isSimilarOpen(value) {
		this.data.set("similar-open", value);
	}

	get identifier() {
		return this.data.get("identifier");
	}

	get favoriteController() {
		return this.application.controllers.find(controller => controller.context.identifier === 'favorite');
	}

	get sectionIdentifier() {
		return this.eventTarget.closest('[data-controller="section"]').id;
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
				this.toggleLikeButton = new mdc.iconButton.MDCIconButtonToggle(
					this.likeButtonTarget
				);
			}
		} else {
			if (this.overlayRipple) {
				this.overlayRipple.destroy();
			}
			if (this.likeButtonRipple) {
				this.likeButtonRipple.destroy();
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
