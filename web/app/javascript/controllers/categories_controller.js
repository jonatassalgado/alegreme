import {Controller}   from "stimulus";

export default class CategoriesController extends Controller {
	static targets = ["wrapper", "chipset"];

	connect() {
		this.chipsetTarget.querySelector(`[data-category-slug="${this.data.get("selected")}"]`).classList.add("mdc-chip--selected");

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
		const categoryUrl  = categoryEl.dataset.categoryUrl;

		this.scrollOffset = {
			position: categoryEl.offsetLeft,
			smooth:   true
		};

		Turbolinks.visit(categoryUrl);
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
