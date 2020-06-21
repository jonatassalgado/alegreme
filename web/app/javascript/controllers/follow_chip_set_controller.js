import ApplicationController from './application_controller'
import {MDCChipSet}          from '@material/chips';


export default class FollowChipSetController extends ApplicationController {
	static targets = ['chipSet', "chip"];

	initialize() {
		this.pubsub = {};

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.sectionIdentifier}.updated`, (data) => {
			setTimeout(() => {
				this.chipSet = new MDCChipSet(this.chipSetTarget);
			}, 550)
		});

		this.destroy = () => {
			this.pubsub.sectionUpdated();
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}


	follow(event) {
		const followPromise = new Promise((resolve, reject) => {
			const chipEl = event.target.closest('[data-target="follow-chip-set.chip"]');

			const data = {
				chipIconElem:    event.target,
				chipElem:        chipEl,
				eventElem:       document.getElementById('event'),
				followable:      chipEl.dataset.followable,
				type:            chipEl.dataset.type,
				action:          chipEl.dataset.followed === 'true' ? 'unfollow' : 'follow',
				expandToSimilar: this.expandToSimilar,
				eventId:         this.eventId,
				identifier:      this.identifier
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
			fetch(`/${data.type}/${data.followable}/${data.action}`, {
				method:      'post',
				headers:     {
					'X-Requested-With': 'XMLHttpRequest',
					'Content-type':     'application/json',
					'Accept':           'text/javascript',
					'X-CSRF-Token':     document.querySelector('meta[name=csrf-token]').content
				},
				credentials: 'same-origin',
				body:        JSON.stringify({
					                            expand_to_similar: data.expandToSimilar,
					                            event_id:          data.eventId,
					                            identifier:        data.identifier
				                            })
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

	get identifier() {
		return this.chipSetTarget.id;
	}

	get expandToSimilar() {
		return this.data.get('expand-to-similar');
	}

	// get componentId() {
	// 	return this.data.get('id');
	// }

	get sectionIdentifier() {
		const section = this.chipSetTarget.closest('[data-controller="section"]');
		if (this.hasChipSetTarget && section) {
			return section.id;
		}
	}


}
