import {Controller} from "stimulus"
import {MDCRipple}  from '@material/ripple';


export default class FavoriteEventsController extends Controller {
	static targets = ["event", "overlay", "title", "date", "remove"];

	initialize() {
		if (this.hasOverlayTarget) {
			MDCRipple.attachTo(this.overlayTarget);
		}
	}


	showEventDetails(event) {
		const self = this;

		self.removeTarget.style.display = "inline";
		self.eventTarget.addEventListener("mouseout", function () {
			self.removeTarget.style.display = "none";
		})
	}


	remove() {
		const self = this;

		fetch(`/events/${self.identifier}/favorite`, {
			method     : 'delete',
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


	get identifier() {
		return this.data.get("identifier")
	}


}
