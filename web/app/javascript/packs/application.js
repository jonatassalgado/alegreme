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
import {MDCSelect} from '@material/select';
import {MDCFormField} from '@material/form-field';
import {MDCCheckbox} from '@material/checkbox';
import {MDCMenu} from '@material/menu';

Turbolinks.scroll = {};

document.addEventListener("turbolinks:load", ()=> {
  
  const elements = document.querySelectorAll("[data-turbolinks-scroll]");

  elements.forEach(function(element){
    
    element.addEventListener("click", ()=> {
      Turbolinks.scroll['top'] = document.scrollingElement.scrollTop;
    });
    
    element.addEventListener("submit", ()=> {
      Turbolinks.scroll['top'] = document.scrollingElement.scrollTop;
    });
    
  });
  
  if (Turbolinks.scroll['top']) {
    document.scrollingElement.scrollTo(0, Turbolinks.scroll['top']);
  }

  Turbolinks.scroll = {};
});


document.addEventListener("turbolinks:load", function() {
  // TopAppBar
  const topAppBarElement = document.querySelector('.mdc-top-app-bar');
  const topAppBar = new MDCTopAppBar(topAppBarElement);

  // List
  // const list = MDCList.attachTo(document.querySelector('.mdc-list'));
  // list.wrapFocus = true;

  // Button
  const buttons = document.querySelectorAll('.mdc-button');
  const icons = document.querySelectorAll('.mdc-icon-button');

  buttons.forEach((button) => {
    new MDCRipple(button);
  })

  icons.forEach((icon) => {
    const buttonToggle = new mdc.iconButton.MDCIconButtonToggle(icon);

    const ripple = new MDCRipple(icon);
    ripple.unbounded = true;
  })

  // Textfield
  const fields = document.querySelectorAll('.mdc-text-field');
  fields.forEach((field) => {
    const chatInput = field.querySelector('[data-target="chat.input"]');
    if (chatInput) { 
      new MDCTextField(field);
    };
  })


  // Select
  const selects = document.querySelectorAll('.mdc-select');
  selects.forEach((select) => {
    new MDCSelect(select);
  })


  // Checkbox
  const checkboxes = document.querySelectorAll('.mdc-checkbox');
  checkboxes.forEach((checkbox) => {
    new MDCCheckbox(checkbox);
  })


  // Menu
  const menus = document.querySelectorAll('.mdc-menu');
  menus.forEach((menu) => {
    new MDCMenu(menu);
  })

});
