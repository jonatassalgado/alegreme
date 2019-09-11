/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// import "postal";
import "morphdom";
import {MDCRipple}      from "@material/ripple";
import {MDCTextField}   from "@material/textfield";
import {MDCSelect}      from "@material/select";
import {MDCCheckbox}    from "@material/checkbox";
import {MDCMenu}        from "@material/menu";
import {MDCSnackbar}    from "@material/snackbar";
import {CacheModule}    from "../modules/cache-module";
import {AnimateModule}  from "../modules/animate-module";
import {LazyloadModule} from "../modules/lazyload-module";
import {PubSubModule}   from "../modules/pubsub-module";
// TODO: JS Event Listners leaks
// import {MDCIconButtonToggle} from "@material/icon-button";
// import {

// 	MDCTopAppBar
// } from "@material/top-app-bar/index";


PubSubModule.init();
CacheModule.activateTurbolinks();
AnimateModule.init();


const initCommonComponents = () => {

	const commonComponents = {
		domEls    : {},
		components: {}
	};

	LazyloadModule.init();

	commonComponents.domEls.buttons = document.querySelectorAll(".mdc-button");
	commonComponents.domEls.fabs    = document.querySelectorAll(".mdc-fab");
	// const icons   = document.querySelectorAll(".mdc-icon-button");

	commonComponents.components.buttons = [];
	commonComponents.domEls.buttons.forEach(button => {
		if (button) {
			commonComponents.components.buttons.push(new MDCRipple(button));
		}
	});

	commonComponents.components.fabs = [];
	commonComponents.domEls.fabs.forEach(fab => {
		if (fab) {
			commonComponents.components.fabs.push(new MDCRipple(fab));
		}
	});

	// icons.forEach(icon => {
	// 	new MDCIconButtonToggle(icon);
	// 	const ripple     = new MDCRipple(icon);
	// 	ripple.unbounded = true;
	// 	document.addEventListener("turbolinks:before-cache", () => {
	// 		ripple.destroy();
	// 	}, false);
	// });

	commonComponents.domEls.fields     = document.querySelectorAll(".mdc-text-field");
	commonComponents.components.fields = [];
	commonComponents.domEls.fields.forEach(field => {
		commonComponents.components.fields.push(new MDCTextField(field))
	});

	commonComponents.domEls.snackbar = document.querySelector(".mdc-snackbar");
	if (commonComponents.domEls.snackbar) {
		commonComponents.components.snackbar = new MDCSnackbar(snackbarElem);
		commonComponents.components.snackbar.open();
	}

	commonComponents.domEls.selects     = document.querySelectorAll(".mdc-select");
	commonComponents.components.selects = [];
	commonComponents.domEls.selects.forEach(select => {
		commonComponents.components.selects.push(new MDCSelect(select));
	});

	commonComponents.domEls.checkboxes     = document.querySelectorAll(".mdc-checkbox");
	commonComponents.components.checkboxes = [];
	commonComponents.domEls.checkboxes.forEach(checkbox => {
		commonComponents.components.checkboxes.push(new MDCCheckbox(checkbox));
	});

	commonComponents.domEls.menus     = document.querySelectorAll(".mdc-menu");
	commonComponents.components.menus = [];
	commonComponents.domEls.menus.forEach(menu => {
		commonComponents.components.menus.push(new MDCMenu(menu));
	});

	document.addEventListener("turbolinks:before-cache", () => {
		delete commonComponents.domEls;
		delete commonComponents.components;
	});
};


// document.addEventListener("DOMContentLoaded", initCommonComponents, {once: true});
document.addEventListener("turbolinks:load", initCommonComponents, {once: true});
document.addEventListener("turbolinks:render", initCommonComponents, false);


import "controllers";


