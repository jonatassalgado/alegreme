// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "./serviceworker-companion"
import "morphdom";

import {Application}            from "stimulus"
import {definitionsFromContext} from "stimulus/webpack-helpers"
import StimulusReflex           from "stimulus_reflex"
import consumer                 from "../channels/consumer"

import {CacheModule}    from "../modules/cache-module";
import {AnimateModule}  from "../modules/animate-module";
import {PubSubModule}   from "../modules/pubsub-module";
import {LazyloadModule} from "../modules/lazyload-module";
import {SnackBarModule} from "../modules/snackbar-module";

PubSubModule.init();
CacheModule.activateTurbolinks();
AnimateModule.init();
LazyloadModule.init();

const application = Application.start();
const context     = require.context("controllers", true, /controller\.js$/);

application.load(definitionsFromContext(context));
StimulusReflex.initialize(application, {consumer})

window.addEventListener("beforeinstallprompt", (e) => {
    e.preventDefault();
});
