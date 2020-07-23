// import ApplicationController from "./application_controller"
// import {FlipperModule}       from "../modules/flipper-module";
// import {PubSubModule}        from "../modules/pubsub-module";
//
// export default class SavesController extends ApplicationController {
//     static targets = ["saves"];
//
//     connect() {
//         super.connect();
//         this.setup();
//     }
//
//     beforeCache() {
//         super.beforeCache();
//         // this.teardown();
//     }
//
//     disconnect() {
//         super.disconnect();
//         this.teardown();
//     }
//
//     setup() {
//         this.pubsub  = {};
//         this.flipper = FlipperModule(`data-collection-${this.id}-flip-key`);
//         this.activeFlip();
//     }
//
//     teardown() {
//         PubSubModule.destroy(this.pubsub);
//         this.flipper.destroy();
//     }
//
//     activeFlip() {
//         this.pubsub.savesStarted = PubSubModule.on("taste->started", (data) => {
//             this.flipper.read()
//             this.element.addEventListener("cable-ready:after-morph", this.flipper.flip);
//         });
//     }
//
//     get id() {
//         return this.savesTarget.id
//     }
//
// }
