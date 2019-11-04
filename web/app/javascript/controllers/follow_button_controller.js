import {Controller} from "stimulus";
import {MDCRipple}  from '@material/ripple';

export default class FollowButtonController extends Controller {
	static targets = ['button', 'text'];

	initialize() {
		this.pubsub       = {};
		this.buttonRipple = new MDCRipple(this.buttonTarget);

		this.pubsub.sectionUpdated = PubSubModule.on(`${this.identifier}.updated`, (data) => {
			this.buttonRipple = new MDCRipple(this.buttonTarget);
		});

		this.destroy = () => {
			this.buttonRipple.destroy();
			this.pubsub.sectionUpdated();
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	follow() {
		const followPromise = new Promise((resolve, reject) => {

			const data = {
				followable: this.data.get('followable'),
				type      : this.data.get('type'),
				action    : this.isFollowed,
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
				method     : 'get',
				headers    : {
					'X-Requested-With': 'XMLHttpRequest',
					'Content-type'    : 'application/json; charset=UTF-8',
					'Accept'          : 'application/json',
					'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
				},
				credentials: 'same-origin'
			})
				.then(
					response => {
						response.json().then(data => {

							if (data.following) {
								this.isFollowed           = true;
								this.textTarget.innerText = 'Seguindo';
								this.buttonTarget.classList.add('mdc-chip--selected');
							} else {
								this.isFollowed           = false;
								this.textTarget.innerText = 'Seguir';
								this.buttonTarget.classList.remove('mdc-chip--selected');
							}

							CacheModule.clearCache(['feed-page']);
						});
					}
				)
				.catch(err => {
					console.log('Fetch Error :-S', err);
				});
		});

		document.addEventListener("turbolinks:before-cache", () => {

		});


	}

	get isFollowed() {
		return this.data.get('followed') === 'true' ? 'unfollow' : 'follow';
	}

	get identifier() {
		return this.data.get('identifier');
	}

	set isFollowed(value) {
		this.data.set('followed', value);
	}

}
