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
		const self = this;

		self.md                 = new MobileDetect(window.navigator.userAgent);
		self.adjustForDevice    = self.md.mobile();
		self.subscriptions      = {};
		self.activeInteractions = true;


		self.subscriptions.savesUpdated = postal.subscribe({
			channel : `saves`,
			topic   : `saves.updated`,
			callback: function (data, envelope) {
				if (data.detail.eventId == self.identifier) {
					self.likeStatus = data.detail.currentEventFavorited;
					self.updateLikeButtonStyle(data.detail.eventId);
				}
			}
		});

		self.subscriptions.filterUpdated = postal.subscribe(
			{
				channel : `${self.sectionIdentifier}`,
				topic   : `${self.sectionIdentifier}.updated`,
				callback: function (data, envelope) {
					if(data.params.similar == self.identifier) {
						self.isSimilarOpen = true;
					}
				}
			});

		document.addEventListener("turbolinks:before-cache", () => {
			self.activeInteractions = false;

			self.subscriptions.filterUpdated.unsubscribe();
			self.subscriptions.savesUpdated.unsubscribe();
		});
	};

	showEventDetails = () => {
		const self = this;

		if (this.md.mobile()) {
		} else {
			if (self.data.get("favorited") === "false") {
				self.likeButtonTarget.style.display = "inline";
			}

			self.eventTarget.addEventListener("mouseout", function () {
				if (self.data.get("favorited") === "false") {
					self.likeButtonTarget.style.display = "none";
				}
			});
		}
	};

	showSimilar = () => {
		const self = this;

		postal.publish({
			channel: `${self.sectionIdentifier}`,
			topic  : `${self.sectionIdentifier}.create`,
			data   : {
				similar     : self.identifier,
				insert_after: self.insertAfter
			}
		});
	};

	openMenu = () => {
		const self    = this;
		const mdcMenu = new MDCMenu(self.menuTarget);
		if (mdcMenu.open) {
			mdcMenu.open = false;
		} else {
			mdcMenu.open = true;
		}
	};


	updateLikeButtonStyle = (eventId) => {
		const self   = this;
		const active = self.data.get('favorited');

		if (active === 'true') {
			self.likeButtonTarget.style.display = 'inline';
			self.likeButtonTarget.classList.add('mdc-icon-button--on')
		} else {
			self.likeButtonTarget.classList.remove('mdc-icon-button--on');
			if (eventId != self.identifier) {
				self.likeButtonTarget.style.display = 'none';
			}
		}
	};

	like() {
		const self = this;

		postal.publish({
			channel: "event",
			topic  : "event.like",
			data   : {}
		});

		fetch(`/events/${self.identifier}/favorite`, {
			method     : self.isFavorited,
			headers    : {
				'X-Requested-With': 'XMLHttpRequest',
				'Content-type'    : 'text/javascript; charset=UTF-8',
				'X-CSRF-Token'    : Rails.csrfToken()
			},
			credentials: 'same-origin'
		})
			.then(
				function (response) {
					response.text().then(function (data) {
						eval(data);
					});
				}
			)
			.catch(function (err) {
				console.log('Fetch Error :-S', err);
			});

	}

	get insertAfter() {
		const self  = this;
		const order = parseInt(self.eventTarget.parentElement.style.order);

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
		self.isSimilarOpen = true;

		this.data.set("similar-open", value);
	}

	get identifier() {
		return this.data.get("identifier");
	}

	get favoriteController() {
		return this.application.controllers.find(function (controller) {
			return controller.context.identifier === 'favorite';
		});
	}

	get sectionIdentifier() {
		return this.eventTarget.closest('[data-controller="section"]').id;
	}

	set likeStatus(status) {
		const self = this;
		self.data.set("favorited", status);
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
		const self = this;

		if (value) {
			if (self.hasOverlayTarget && !self.overlayRipple) {
				self.overlayRipple = new MDCRipple(self.overlayTarget);
			}
			if (self.hasLikeButtonTarget) {
				self.toggleLikeButton = new mdc.iconButton.MDCIconButtonToggle(
					self.likeButtonTarget
				);
			}
		} else {
			if (self.overlayRipple) {
				self.overlayRipple.destroy();
			}
			if (self.likeButtonRipple) {
				self.likeButtonRipple.destroy();
			}
		}
	}

	set adjustForDevice(isMobile) {
		const self        = this;
		const isFavorited = self.data.get("favorited") === "false";
		const isSingle    = self.data.get("modifier") === "single";

		if (isMobile) {
		} else {
			if (isFavorited && !isSingle) {
				self.likeButtonTarget.style.display = "none";
			}
		}
	}
}
