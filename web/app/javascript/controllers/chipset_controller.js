import {Controller}   from "stimulus";

export default class ChipsetController extends Controller {
	static targets = ["wrapper", "chipset"];

	connect() {
		if (this.hasChipsetTarget && this.data.has("selected")) {
			this.chipsetTarget.querySelector(`[data-chipset-slug="${this.data.get("selected")}"]`).classList.add("mdc-chip--selected");
		}

		this.destroy = () => {

		}

		document.addEventListener('turbolinks:before-cache', this.destroy, false);

		if (this.chipsetTarget.querySelector(".mdc-chip--selected")) {
			this.scrollOffset = {
				position: this.chipsetTarget.querySelector(".mdc-chip--selected").offsetLeft,
				smooth:   false
			};
		}

	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

	select(event) {
		const categoryEl   = event.currentTarget;
		const chipsetUrl  = categoryEl.dataset.chipsetUrl;

		this.scrollOffset = {
			position: categoryEl.offsetLeft,
			smooth:   true
		};

		PubSubModule.emit("chipset.update", {});

		setTimeout(() => {
			Turbolinks.visit(chipsetUrl);
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
