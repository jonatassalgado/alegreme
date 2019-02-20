/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('Hello World from Webpacker')

import 'controllers'
import * as mdc from 'material-components-web';

import {MDCTopAppBar} from '@material/top-app-bar/index';
import {MDCList} from '@material/list';
import {MDCRipple} from '@material/ripple';
import {MDCTextField} from '@material/textfield';




document.addEventListener("turbolinks:load", function() {
    // TopAppBar
    const topAppBarElement = document.querySelector('.mdc-top-app-bar');
    const topAppBar = new MDCTopAppBar(topAppBarElement);

    // List
    // const list = MDCList.attachTo(document.querySelector('.mdc-list'));
    // list.wrapFocus = true;

    // Button
    const buttons = document.querySelectorAll('.mdc-button');
    buttons.forEach((button) => {
      new MDCRipple(button);
    })

    // Textfield
    const textField = new MDCTextField(document.querySelector('.mdc-text-field'));
});
