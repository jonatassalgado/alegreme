// import {
//   Controller
// } from "stimulus";
// import {
//   MDCRipple
// } from '@material/ripple';
//
// // import * as MobileDetect from "mobile-detect";
//
// export default class HeroController extends Controller {
//   static targets = [
//     "hero",
//     "close"
//   ];
//
//   initialize() {
//     this.activeInteractions = true;
//
//     document.addEventListener("turbolinks:before-cache", () => {
//       this.activeInteractions = false;
//     });
//   }
//
//   show() {
//     this.visibility = "visible";
//   }
//
//   close() {
//     this.visibility = "hidden";
//   }
//
//   set visibility(value) {
//     self = this;
//
//     switch (value) {
//       case "visible":
//         self.heroTarget.classList.remove("me-hero--hidden");
//         break;
//       case "hidden":
//         self.heroTarget.classList.add("me-hero--hidden");
//         break;
//     }
//   }
//
//   set activeInteractions(value) {
//     const self = this;
//
//     if (value) {
//       if (self.hasCloseTarget && !self.closeRipple) {
//         self.closeRipple = new MDCRipple(self.closeTarget);
//         self.closeRipple.unbounded = true;
//       }
//     } else {
//       if (self.closeRipple) {
//         self.closeRipple.destroy();
//       }
//     }
//   }
//
// }