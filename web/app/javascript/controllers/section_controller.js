import ApplicationController from "./application_controller"
import {LazyloadModule}      from "modules/lazyload-module";
import {MDCRipple}           from "@material/ripple";
import * as MobileDetect     from "mobile-detect";
import Flipping              from "flipping";
import {ProgressBarModule}   from "../modules/progressbar-module";
import {AnimateModule}       from "modules/animate-module"

export default class SectionController extends ApplicationController {
    static targets = ["section", "filter", "scrollContainer", "loadMoreButton", "seeAll", "personas", "categories",
                      "grid", "ocurrences", "kinds"];

    connect() {
        super.connect();
        this.scrollLeft = this.data.get("turbolinksPersistScroll");
        this.md         = new MobileDetect(window.navigator.userAgent);
        this.pubsub     = {};
        this.ripples    = [];
        this.rootMargin = this.md.mobile() ? "1000px" : "500px";
        // this.flipping   = new Flipping({
        // 	                               attribute: `data-collection-${this.identifier}-flip-key`
        //                                });

        this.loadMoreButtonTargets.forEach((button) => {
            this.ripples.push(new MDCRipple(button));
        });

        if (this.data.get("infiniteScroll") === "true") {
            this.observer = new IntersectionObserver((entries, observer) => {
                                                         entries.forEach((entry) => {

                                                             if (this.hasLoadMoreButtonTarget) {
                                                                 if (entry.isIntersecting) {
                                                                     entry.target.disabled  = true;
                                                                     entry.target.innerText = "Carregando...";
                                                                     this.loadMoreHere();
                                                                 } else {

                                                                 }
                                                             }
                                                         })
                                                     },
                                                     {
                                                         threshold:  0.1,
                                                         rootMargin: this.rootMargin
                                                     }
            );

            this.loadMoreButtonTargets.forEach((loadMoreButton) => {
                this.observer.observe(loadMoreButton);
            });
        }

        // this.pubsub.sectionUpdated = PubSubModule.on(`${this.identifier}.updated`, (data) => {
        //     if (!this.md.mobile()) {
        //         const flipPromise = new Promise((resolve, reject) => {
        //             this.flipping.flip();
        //
        //             let delay   = 0.035;
        //             let counter = 0;
        //             let states  = Object.keys(this.flipping.states);
        //
        //             const flipped = states.forEach((key) => {
        //                 counter++;
        //
        //                 const state = this.flipping.states[key];
        //                 if (state.element === undefined) {
        //                     return;
        //                 }
        //
        //                 if (states.length > 48 && counter < (states.length - 8)) {
        //                     return;
        //                 }
        //
        //                 if (state.type === "MOVE" && state.delta) {
        //                     state.element.style.transition = "";
        //                     state.element.style.transform  = `translateY(${state.delta.top}px) translateX(${state.delta.left}px)`;
        //                 }
        //                 if (state.type === "ENTER") {
        //                     state.element.style.opacity   = 0;
        //                     state.element.style.transform = `scale(0.8)`;
        //                 }
        //                 requestAnimationFrame(() => {
        //                     if (state.type === "MOVE" &&
        //                         state.delta) {
        //                         state.element.style.transition = `transform 0.6s cubic-bezier(.54,.01,.45,.99)`;
        //                         state.element.style.transform  = "";
        //                         state.element.style.opacity    = 1;
        //                     }
        //                     if (state.type === "ENTER") {
        //                         state.element.style.transition = `transform 0.4s cubic-bezier(0,.16,.45,.99) ${delay}s, opacity 0.4s cubic-bezier(0,.16,.45,.99) ${delay}s`;
        //                         state.element.style.transform  = "";
        //                         state.element.style.opacity    = 1;
        //                     }
        //                     delay = delay + 0.035;
        //                 });
        //             });
        //             resolve(flipped)
        //         });
        //         flipPromise.then(() => {
        //             ProgressBarModule.hide();
        //         });
        //     } else {
        //         ProgressBarModule.hide();
        //     }
        //     LazyloadModule.lazyloadFeed();
        //     this.hasMoreEventsToLoad();
        //     this.data.set("load-more-loading", false);
        //     this.scrollLeft = 0;
        // });

        this.destroy = () => {
            this.turbolinksPersistScroll     = this.scrollContainerTarget.scrollLeft;
            this.sectionTarget.style.opacity = 1;
            this.ripples.forEach((ripple) => {
                ripple.destroy();
            });
        };

        document.addEventListener("turbolinks:before-cache", this.destroy, false);
    }


    disconnect() {
        document.removeEventListener("turbolinks:before-cache", this.destroy, false);
    }

    seeMoreInNewPage() {
        if (this.data.has("continueToPath")) {
            AnimateModule.animatePageHide();
            setTimeout(() => {
                Turbolinks.visit(this.data.get("continueToPath"));
            }, 250)
        }
    }

    loadMoreHere() {
        this.data.set("loadMoreLoading", true);
        this.data.set("limit", parseInt(this.data.get("limit")) + 16);

        this.stimulate("Event#update_collection", this.gridTarget, {
            limit: this.data.get("limit")
        })
            .then(payload => {
                this.data.set("loadMoreLoading", false);
            })
            .catch(payload => {

            })
    }

    set turbolinksPersistScroll(value) {
        this.data.set("turbolinksPersistScroll", value);
    }

    set scrollLeft(value) {
        if (value >= 0) {
            this.scrollContainerTarget.scrollLeft = value;
        }
    }

    get identifier() {
        return this.data.get("identifier");
    }

}
