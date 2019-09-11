const initSelectComponents = () => {

	const selects = {
		els: document.querySelectorAll(".mdc-select"),
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

document.addEventListener("turbolinks:load", initSelectComponents, {once: true});
document.addEventListener("turbolinks:render", initSelectComponents, false);

