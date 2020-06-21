import ApplicationController from './application_controller'
import * as MobileDetect     from "mobile-detect";

export default class SaveButtonController extends ApplicationController {
	static targets = ['saveButton'];

	connect() {
		this.pubsub          = {};
		this.md              = new MobileDetect(window.navigator.userAgent);
		this.adjustForDevice = this.md.mobile();

		this.pubsub.savesUpdated = PubSubModule.on(`saves.updated`, (data) => {
			if (data.detail.resourceId == this.resourceId) {
				this.saveStatus = data.detail.currentResourceFavorited;
				this.updateSaveButtonStyle(data.detail.resourceId, data.detail.currentResourceFavorited);
			}
		});

		this.destroy = () => {
			this.pubsub.savesUpdated();
		}

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	like() {
		this.updateSaveButtonStyle(this.resourceId, !this.saveStatus);

		PubSubModule.emit('event.like');

		fetch(`/api/taste/${this.resourceName}/${this.resourceId}/${this.isSaved}`, {
			method:      'post',
			headers:     {
				'X-Requested-With': 'XMLHttpRequest',
				'Content-type':     'text/javascript; charset=UTF-8',
				'X-CSRF-Token':     document.querySelector('meta[name=csrf-token]').content
			},
			credentials: 'same-origin'
		})
			.then(
				response => {
					response.text().then(data => {
						eval(data);
						CacheModule.clearCache(['feed-page', 'events-page'], {
							event: {
								identifier: this.resourceId
							}
						});
					});
				}
			)
			.catch(err => {
				console.log('Fetch Error :-S', err);
			});
	}

	updateSaveButtonStyle(resourceId, saveStatus) {
		if (this.hasSaveButtonTarget) {
			if (saveStatus === true) {
				this.saveButtonTarget.style.display = 'inline';
				this.saveButtonTarget.classList.add('mdc-icon-button--on')
			} else {
				this.saveButtonTarget.classList.remove('mdc-icon-button--on');
				if (resourceId != this.resourceId) {
					this.saveButtonTarget.style.display = 'none';
				}
			}
		}
	};

	set adjustForDevice(isMobile) {
		const isSaved  = this.saveStatus === false;
		const isSingle = this.data.get("modifier") === "single";

		if (isMobile) {
		} else {
			if (isSaved && !isSingle) {
				this.saveButtonTarget.style.display = "none";
			}
		}
	}

	get isSaved() {
		if (this.saveStatus === true) {
			return "unsave";
		} else {
			return "save";
		}
	}

	get saveStatus() {
		return JSON.parse(this.data.get("saved"))
	}

	set saveStatus(status) {
		this.data.set("saved", status);
	}

	get resourceId() {
		return this.data.get('resourceId')
	}

	get resourceName() {
		return this.data.get('resourceName')
	}

	get isPreview() {
		return document.documentElement.hasAttribute('data-turbolinks-preview');
	}

}
