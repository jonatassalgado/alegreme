import {MDCSelect} from "@material/select"

const SelectComponentsInitializer = (() => {

	const module = {};

	module.init = () => {
		console.log("[INITIALIZE]: started")

		const selects = {
			els       : document.querySelectorAll(".mdc-select"),
			components: []
		};


		selects.els.forEach(select => {
			selects.components.push(new MDCSelect(select));
		});

		document.addEventListener("turbolinks:before-cache", () => {
			delete selects.els;
			delete selects.components;
		});

	};

	document.addEventListener("turbolinks:load", module.init, {once: true});
	document.addEventListener("turbolinks:render", module.init, false);

	return module;
})();

export {SelectComponentsInitializer}

