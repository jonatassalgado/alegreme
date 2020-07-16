import ApplicationController from "./application_controller"
import {MDCRipple}           from "@material/ripple";
import {ProgressBarModule}   from "../modules/progressbar-module";
import {AnimateModule}       from "../modules/animate-module"
import {FlipperModule}       from "../modules/flipper-module";
import {MobileDetector}      from "../modules/mobile-detector-module";

export default class SectionController extends ApplicationController {
    static targets = ["section", "filter", "scrollContainer", "loadMoreButton", "seeAll", "personas", "categories",
                      "grid", "ocurrences", "kinds"];

    connect() {
        super.connect();
        this.scrollLeft = this.data.get("turbolinksPersistScroll");
        this.flipper    = FlipperModule(`data-collection-${this.identifier}-flip-key`);
        this.pubsub     = {};
        this.ripples    = [];
        this.observer   = new IntersectionObserver((entries, observer) => {
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

        this.activeLoadMoreButton();

        this.pubsub.savesUpdate = PubSubModule.on("save-button.clicked", (data) => {
            this.flipper.read()
            document.addEventListener("cable-ready:after-morph", this.flipper.flip, {once: true});
        });

        document.addEventListener("turbolinks:before-cache", this.beforeCache.bind(this))
        document.addEventListener("cable-ready:after-morph", this.activeLoadMoreButton.bind(this))
    }

    beforeCache() {
        this.turbolinksPersistScroll = this.scrollContainerTarget.scrollLeft;
    }

    disconnect() {
        this.sectionTarget.style.opacity = 1;
        this.pubsub.savesUpdate();
        this.flipper.destroy();
        this.observer.disconnect();
        this.ripples.forEach((ripple) => {
            ripple.destroy();
        });
        document.removeEventListener("turbolinks:before-cache", this.beforeCache.bind(this))
        document.removeEventListener("cable-ready:after-morph", this.activeLoadMoreButton.bind(this))
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
            this.data.set("loadMoreLoading", true);
            this.data.set("limit", parseInt(this.data.get("limit")) + 16);

            this.stimulate("Event#update_collection", this.gridTarget, {
                limit: this.data.get("limit")
            })
                .then(payload => {
                    ProgressBarModule.hide();
                    this.data.set("loadMoreLoading", false);
                })
                .catch(payload => {

                })
        }
    }

    activeLoadMoreButton() {
        this.rootMargin = MobileDetector.mobile() ? "500px" : "250px";

        this.loadMoreButtonTargets.forEach((button) => {
            this.ripples.push(new MDCRipple(button));
        });

        if (this.data.get("infiniteScroll") === "true") {
            this.loadMoreButtonTargets.forEach((loadMoreButton) => {
                this.observer.observe(loadMoreButton);
            });
        }
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
