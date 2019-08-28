/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log("Hello World from Webpacker");

import "postal";
import "morphdom";
import "controllers";

import {MDCIconButtonToggle} from "@material/icon-button";

import {
	MDCTopAppBar
} from "@material/top-app-bar/index";
import {
	MDCRipple
} from "@material/ripple";
import {
	MDCTextField
} from "@material/textfield";
import {
	MDCSelect
} from "@material/select";
import {
	MDCCheckbox
} from "@material/checkbox";
import {
	MDCMenu
} from "@material/menu";
import {
	MDCSnackbar
} from "@material/snackbar";
import {
	CacheModule
} from "../modules/cache-module";
import {
	AnimateModule
} from "../modules/animate-module";

CacheModule.activateTurbolinks();
AnimateModule.init();

const applicationScript = () => {
	// TopAppBar
	const topAppBarElement = document.querySelector(".mdc-top-app-bar");
	const topAppBar        = new MDCTopAppBar(topAppBarElement);

	// Button
	const buttons = document.querySelectorAll(".mdc-button");
	const fabs    = document.querySelectorAll(".mdc-fab");
	const icons   = document.querySelectorAll(".mdc-icon-button");

	buttons.forEach(button => {
		if (button) {
			new MDCRipple(button);
		}
	});

	fabs.forEach(fab => {
		if (fab) {
			new MDCRipple(fab);
		}
	});

	icons.forEach(icon => {
		new MDCIconButtonToggle(icon);
		const ripple     = new MDCRipple(icon);
		ripple.unbounded = true;
	});

	// Textfield
	const fields = document.querySelectorAll(".mdc-text-field");
	fields.forEach(field => {
		// const chatInput = field.querySelector('[data-target="chat.input"]');
		// if (chatInput) {
		new MDCTextField(field);
		// }
	});

	// Snackbar
	const snackbarElem = document.querySelector(".mdc-snackbar");
	if (snackbarElem) {
		const snackbar = new MDCSnackbar(snackbarElem);
		snackbar.open();
	}

	// Select
	const selects = document.querySelectorAll(".mdc-select");
	selects.forEach(select => {
		new MDCSelect(select);
	});

	// Checkbox
	const checkboxes = document.querySelectorAll(".mdc-checkbox");
	checkboxes.forEach(checkbox => {
		new MDCCheckbox(checkbox);
	});

	// Menu
	const menus = document.querySelectorAll(".mdc-menu");
	menus.forEach(menu => {
		new MDCMenu(menu);
	});

};

document.addEventListener("DOMContentLoaded", applicationScript, false);
document.addEventListener("turbolinks:load", applicationScript, false);

