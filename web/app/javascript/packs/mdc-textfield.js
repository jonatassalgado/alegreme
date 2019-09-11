const initTextfieldComponents = () => {

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

document.addEventListener("turbolinks:load", initTextfieldComponents, {once: true});
document.addEventListener("turbolinks:render", initTextfieldComponents, false);

