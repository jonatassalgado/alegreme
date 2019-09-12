import {MDCTextField} from "@material/textfield"

const TextfieldComponentsInitializer = (() => {

	const module = {};

	module.init = () => {
		const textfields = {
			els: document.querySelectorAll(".mdc-text-field"),
			components: []
		};


		textfields.els.forEach(textfield => {
			textfields.components.push(new MDCTextField(textfield));
		});

		document.addEventListener("turbolinks:before-cache", () => {
			delete textfields.els;
			delete textfields.components;
		});

	};

	document.addEventListener("turbolinks:load", module.init, {once: true});
	document.addEventListener("turbolinks:render", module.init, false);

	return module;
})();

export {TextfieldComponentsInitializer}

