import ApplicationController from './application_controller'

export default class ChipSetController extends ApplicationController {
	static targets = ["wrapper", "chipSet"];

	connect() {
		super.connect();
		this.setup();
	}

	beforeCache() {
		super.beforeCache();
		this.teardown();
	}

	disconnect() {
		super.disconnect();
	}

	setup() {
		if (this.hasChipSetTarget && this.data.get("selected") != "") {
			this.chipSetTarget.querySelector(`[data-chip-set-slug="${this.data.get("selected")}"]`).classList.add("mdc-chip--selected");
		}

		if (this.chipSetTarget.querySelector(".mdc-chip--selected")) {
			this.scrollOffset = {
				position: this.chipSetTarget.querySelector(".mdc-chip--selected").offsetLeft,
				smooth:   false
			};
		}
	}

	teardown() {

	}

	select(event) {
		const categoryEl = event.currentTarget;
		const chipSetUrl = categoryEl.dataset.chipSetUrl;

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
