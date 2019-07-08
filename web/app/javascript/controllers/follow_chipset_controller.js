import {Controller} from "stimulus";
import {MDCChipSet} from '@material/chips';
import * as mdc     from "material-components-web";


export default class FollowChipsetController extends Controller {
	static targets = ['chipset', "chip"];

	initialize() {
		const self         = this;
		self.subscriptions = {};
		// self.chipSet       = new MDCChipSet(self.chipsetTarget);

		self.subscriptions.filterUpdated = postal.subscribe(
			{
				channel : `${self.sectionIdentifier}`,
				topic   : `${self.sectionIdentifier}.updated`,
				callback: function (data, envelope) {
					setTimeout(() => {
						self.chipSet = new MDCChipSet(self.chipsetTarget);
					}, 550)
				}
			});
	}


	follow(event) {
		const self = this;

		const followPromise = new Promise(function (resolve, reject) {
			const data = {
				chipIconElem: event.target,
				chipElem    : event.target.parentElement,
				eventElem   : document.getElementById('event'),
				followable  : event.target.parentElement.dataset.followable,
				type        : event.target.parentElement.dataset.type,
				location    : self.location,
				action      : event.target.parentElement.dataset.followed === 'true' ? 'unfollow' : 'follow',
				eventId     : self.eventId
			};

			if (Object.values(data).map((value) => {
				return value !== undefined
			})) {
				resolve(data);
			} else {
				reject(Error("It broke"));
			}
		});

		followPromise.then((data) => {
			fetch(`/${data.type}/${data.followable}/${data.action}?event_id=${data.eventId}`, {
				method     : 'get',
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
							CacheSystem.clearCache(['feed-page']);
						});
					}
				)
				.catch(function (err) {
					console.log('Fetch Error :-S', err);
				});
		});

		document.addEventListener("turbolinks:before-cache", () => {
			self.chipSet.destroy();
		});


	}

	get eventId() {
		const self    = this;
		const eventEl = document.getElementById('event');
		if (eventEl) {
			return eventEl.dataset.eventIdentifier;
		}
	}

	get location() {
		return this.data.get('location')
	}

	get sectionIdentifier() {
		return this.chipsetTarget.closest('[data-controller="section"]').id;
	}


}
