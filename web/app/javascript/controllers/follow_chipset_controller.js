import {Controller} from "stimulus";
import {MDCChipSet} from '@material/chips';
import * as mdc     from "material-components-web";


export default class FollowChipsetController extends Controller {
	static targets = ['chipset', "chip"];

	initialize() {
		this.subscriptions = {};

		this.subscriptions.filterUpdated = postal.subscribe(
			{
				channel : `${this.sectionIdentifier}`,
				topic   : `${this.sectionIdentifier}.updated`,
				callback: (data, envelope) => {
					setTimeout(() => {
						this.chipSet = new MDCChipSet(this.chipsetTarget);
					}, 550)
				}
			});
	}


	follow(event) {
		const followPromise = new Promise((resolve, reject) => {
			const data = {
				chipIconElem   : event.target,
				chipElem       : event.target.parentElement,
				eventElem      : document.getElementById('event'),
				followable     : event.target.parentElement.dataset.followable,
				type           : event.target.parentElement.dataset.type,
				expandToSimilar: this.expandToSimilar,
				action         : event.target.parentElement.dataset.followed === 'true' ? 'unfollow' : 'follow',
				eventId        : this.eventId
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
			fetch(`/${data.type}/${data.followable}/${data.action}?event_id=${data.eventId}&expand_to_similar=${data.expandToSimilar}`, {
				method     : 'get',
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
							CacheModule.clearCache(['feed-page']);
						});
					}
				)
				.catch(err => {
					console.log('Fetch Error :-S', err);
				});
		});

		document.addEventListener("turbolinks:before-cache", () => {
			this.chipSet.destroy();
		});


	}

	get eventId() {
		const eventEl = document.getElementById('event');
		if (eventEl) {
			return eventEl.dataset.eventIdentifier || null;
		} else {
			return this.data.get('similar-to') || null;
		}
	}

	get expandToSimilar() {
		return this.data.get('expand-to-similar');
	}

	get sectionIdentifier() {
		const section = this.chipsetTarget.closest('[data-controller="section"]');
		if (this.hasChipsetTarget && section) {
			return section.id;
		}
	}


}
