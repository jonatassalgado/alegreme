import {Controller}        from "stimulus";
import {MDCRipple}         from "@material/ripple";

export default class MovieCollectionController extends Controller {
	static targets = ['collection', 'scrollContainer'];

	initialize() {
		this.scrollLeft = this.data.get('turbolinksPersistScroll');


		this.destroy = () => {
			this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}


	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	set turbolinksPersistScroll(value) {
		this.data.set('turbolinksPersistScroll', value);
	}

	set scrollLeft(value) {
		if (value >= 0) {
			this.scrollContainerTarget.scrollLeft = value;
		}
	}

}
