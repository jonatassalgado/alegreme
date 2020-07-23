import ApplicationController from "./application_controller"
import {ProgressBarModule}   from "../modules/progressbar-module";
import {AnimateModule}       from "../modules/animate-module"
import {MobileDetector}      from "../modules/mobile-detector-module";
import {PubSubModule}        from "../modules/pubsub-module";

export default class SectionController extends ApplicationController {
    static targets = ["section", "filter", "scrollContainer", "loadMoreHorizontal", "loadMoreVertical", "seeAll",
                      "grid"];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {
        this.scrollLeft = this.data.get("turbolinksPersistScroll");
        this.pubsub     = {};
        this.observer   = new IntersectionObserver((entries, observer) => {
                                                       entries.forEach((entry) => {
                                                           if (entry.isIntersecting) {
                                                               entry.target.disabled = true;
                                                               this.loadMoreHere();
                                                           }
                                                       })
                                                   },
                                                   {
                                                       threshold:  0.1,
                                                       rootMargin: this.rootMargin
                                                   });

        this.activeLoadMoreButton();

        this.pubsub.filterSelectStarted = PubSubModule.on("filter#select->started", data => {
            if (this.hasFilterTarget) {
                this.filterTarget.classList.add("pointer-events-none");
                this.gridTarget.classList.add("opacity-50");
            }
        })

        this.pubsub.filterSelectFinished = PubSubModule.on("filter#select->finished", data => {
            if (this.hasFilterTarget) {
                this.filterTarget.classList.remove("pointer-events-none");
                this.gridTarget.classList.remove("opacity-50");
            }
        })

        document.addEventListener("cable-ready:after-morph", this.activeLoadMoreButton.bind(this), {once: true})
    }

    teardown() {
        if (this.hasScrollContainerTarget) {
            this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
        }
        PubSubModule.destroy(this.pubsub);
        this.observer.disconnect();
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
        if (this.isActionCableConnectionOpen()) {
            ProgressBarModule.show();
            PubSubModule.emit("section#loadMoreHere->started")
            this.data.set("limit", parseInt(this.data.get("limit")) + 16);

            this.stimulate("Event#update_collection", this.gridTarget, {
                limit: this.data.get("limit")
            }).then(payload => {
                PubSubModule.emit("section#loadMoreHere->finished")
                ProgressBarModule.hide();
            }).catch(payload => {

            })
        }
    }

    activeLoadMoreButton() {
        this.rootMargin = MobileDetector.mobile() ? "500px" : "250px";

        if (this.data.get("infiniteScrollHorizontal") === "true") {
            this.loadMoreHorizontalTargets.forEach((loadMoreButton) => {
                this.observer.observe(loadMoreButton);
            });
        }

        if (this.data.get("infiniteScrollVertical") === "true") {
            this.loadMoreVerticalTargets.forEach((loadMoreButton) => {
                this.observer.observe(loadMoreButton);
            });
        }
    }

    set turbolinksPersistScroll(value) {
        this.data.set("turbolinksPersistScroll", value);
    }

    set scrollLeft(value) {
        if (this.hasScrollContainerTarget && value >= 0) {
            this.scrollContainerTarget.scrollLeft = value;
        }
    }

    get identifier() {
        return this.data.get("identifier");
    }

}
