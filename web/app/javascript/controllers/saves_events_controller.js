import {Controller} from "stimulus"
import {MDCRipple}  from '@material/ripple';


export default class SavesEventsController extends Controller {
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
		fetch(`/api/taste/events/${this.identifier}/unsave`, {
			method     : 'post',
			headers    : {
				'X-Requested-With': 'XMLHttpRequest',
				'Content-type'    : 'text/javascript; charset=UTF-8',
				'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
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
