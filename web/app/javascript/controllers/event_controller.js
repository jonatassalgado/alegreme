import ApplicationController from "./application_controller"
import {MDCRipple}           from "@material/ripple";
import {MDCIconButtonToggle} from "@material/icon-button";
import {AnimateModule}       from "../modules/animate-module";
import {MobileDetector}      from "../modules/mobile-detector-module";

export default class EventController extends ApplicationController {
    static targets = [
        "event",
        "overlay",
        "name",
        "place",
        "date",
        "like",
        "likeButton",
        "similar"
    ];

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
        if (this.hasOverlayTarget) {
            this.overlayRipple = new MDCRipple(this.overlayTarget);
        }
        if (this.hasLikeButtonTarget) {
            this.toggleLikeButton = new MDCIconButtonToggle(
                this.likeButtonTarget
            );
        }
    }

    teardown() {
        if (this.overlayRipple) {
            this.overlayRipple.destroy();
        }
        if (this.toggleLikeButton) {
            this.toggleLikeButton.destroy();
        }
    }

    handleEventClick() {
        AnimateModule.animatePageHide();
    }

    handlePlaceClick() {
        AnimateModule.animatePageHide();
    }

    showEventDetails() {
        if (MobileDetector.mobile()) {
        } else {
            if (this.data.get("favorited") === "false" && this.hasLikeButtonTarget) {
                this.likeButtonTarget.style.display = "inline";
            }

            this.eventTarget.addEventListener("mouseout", () => {
                if (this.data.get("favorited") === "false" && this.hasLikeButtonTarget) {
                    this.likeButtonTarget.style.display = "none";
                }
            });
        }
    };

    showSimilar() {
        this.similarLoading = true;
        this.stimulate("Event#show_similar", this.eventTarget, {
            show_similar_to: this.identifier,
            in_this_section: this.sectionIdentifier
        })
            .then(payload => {
                this.setup();
                this.similarLoading           = false;
                this.similarOpen              = true;
                this.scrollToSimilarContainer = true;
            })
            .catch(payload => {

            })
    };

    readMore() {
        this.data.set("description-open", true);
    }

    get limit() {
        return this.data.get("limit");
    }

    get similarOpen() {
        return this.data.get("similarOpen");
    }

    set similarOpen(value) {
        this.data.set("similar-open", value);
    }

    set similarLoading(value) {
        this.data.set("similar-loading", value);
    }

    get identifier() {
        return this.data.get("identifier");
    }

    get sectionIdentifier() {
        const section = this.eventTarget.closest("[data-controller=\"section\"]");

        if (this.hasEventTarget && section) {
            return section.id;
        }
    }

    set scrollToSimilarContainer(value) {
        if (value) {
            requestAnimationFrame(() => {
                const similarEl = this.eventTarget.closest(".me-section")
                                      .querySelector(".me-similar")
                if (similarEl) {
                    const offsetTop = similarEl.offsetTop - 150
                    window.scrollTo({
                                        top:      offsetTop,
                                        behavior: "smooth"
                                    })
                }
            })
        }
    }

}
