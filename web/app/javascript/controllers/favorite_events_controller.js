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
		this.removeTarget.style.display = "inline";
		this.eventTarget.addEventListener("mouseout", () => {
			this.removeTarget.style.display = "none";
		})
	}


	remove() {
		fetch(`/events/${this.identifier}/favorite`, {
			method     : 'delete',
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


	get identifier() {
		return this.data.get("identifier")
	}


}
