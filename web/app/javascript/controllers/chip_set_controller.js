import {Controller}   from "stimulus";

export default class ChipSetController extends Controller {
	static targets = ["wrapper", "chipSet"];

	connect() {
		
		if (this.hasChipSetTarget && this.data.get("selected") != "") {
			this.chipSetTarget.querySelector(`[data-chip-set-slug="${this.data.get("selected")}"]`).classList.add("mdc-chip--selected");
		}

		this.destroy = () => {

		}

		document.addEventListener('turbolinks:before-cache', this.destroy, false);

		if (this.chipSetTarget.querySelector(".mdc-chip--selected")) {
			this.scrollOffset = {
				position: this.chipSetTarget.querySelector(".mdc-chip--selected").offsetLeft,
				smooth:   false
			};
		}

	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	select(event) {
		const categoryEl   = event.currentTarget;
		const chipSetUrl  = categoryEl.dataset.chipSetUrl;

		this.scrollOffset = {
			position: categoryEl.offsetLeft,
			smooth:   true
		};

		PubSubModule.emit("chip-set.update", {});

		setTimeout(() => {
			Turbolinks.visit(chipSetUrl);
		}, 500)
	}

	set scrollOffset(values) {
		if (values.smooth) {
			this.wrapperTarget.style.scrollBehavior = "smooth";
		}

		this.wrapperTarget.scrollTo(values.position - 24, 0)

		if (values.smooth) {
			this.wrapperTarget.style.scrollBehavior = "";
		}
	}

}
