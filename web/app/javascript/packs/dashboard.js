import "morphdom";
import "chartkick"
import "chart.js"

import {Application}            from "stimulus"
import {definitionsFromContext} from "stimulus/webpack-helpers"


import {CacheModule}       from "../modules/cache-module";
import {AnimateModule}     from "../modules/animate-module";
import {PubSubModule}      from "../modules/pubsub-module";

CacheModule.activateTurbolinks();
AnimateModule.init();

const application = Application.start();
const context     = require.context("controllers", true, /controller\.js$/);

application.load(definitionsFromContext(context));
