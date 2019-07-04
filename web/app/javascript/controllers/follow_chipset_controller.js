import {Controller} from "stimulus";
import {MDCChipSet} from '@material/chips';


export default class FollowChipsetController extends Controller {
	static targets = ['chipset', "chip"];

	initialize() {
		const self      = this;
		self.chipSet    = new MDCChipSet(self.chipsetTarget);
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
				action      : event.target.parentElement.dataset.followed === 'true' ? 'unfollow' : 'follow',
				eventId     : document.getElementById('event').dataset.eventIdentifier
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
						});
					}
				)
				.catch(function (err) {
					console.log('Fetch Error :-S', err);
				});
		})


	}


}
