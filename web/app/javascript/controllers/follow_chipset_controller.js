import {Controller} from "stimulus";
import {MDCChipSet} from '@material/chips';


export default class FollowChipsetController extends Controller {
	static targets = ['chipset', "chip"];

	initialize() {
		this.pubsub = {};

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.sectionIdentifier}.updated`, (data) => {
			setTimeout(() => {
				this.chipSet = new MDCChipSet(this.chipsetTarget);
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
			const chipEl = event.target.closest('[data-target="follow-chipset.chip"]');

			const data = {
				chipIconElem   : event.target,
				chipElem       : chipEl,
				eventElem      : document.getElementById('event'),
				followable     : chipEl.dataset.followable,
				type           : chipEl.dataset.type,
				action         : chipEl.dataset.followed === 'true' ? 'unfollow' : 'follow',
				expandToSimilar: this.expandToSimilar,
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
					'Accept'          : 'text/javascript',
					'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
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

	// get componentId() {
	// 	return this.data.get('id');
	// }

	get sectionIdentifier() {
		const section = this.chipsetTarget.closest('[data-controller="section"]');
		if (this.hasChipsetTarget && section) {
			return section.id;
		}
	}


}
