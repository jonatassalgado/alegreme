import ApplicationController from "./application_controller"
import {MDCMenu}             from "@material/menu";
import {MDCRipple}           from "@material/ripple";
import {MDCIconButtonToggle} from "@material/icon-button";
import * as MobileDetect     from "mobile-detect";
import {ProgressBarModule}   from "../modules/progressbar-module";
import {AnimateModule}       from "../modules/animate-module";
import Flipping              from "flipping";

export default class EventController extends ApplicationController {
    static targets = [
        "event",
        "overlay",
        "name",
        "place",
        "date",
        "like",
        "likeButton",
        "likeCount",
        "moreButton",
        "menu",
        "similar"
    ];

    connect() {
        super.connect();

        this.md                 = new MobileDetect(window.navigator.userAgent);
        this.activeInteractions = true;

        this.flipping = new Flipping({
                                         attribute: `data-collection-${this.sectionIdentifier}-flip-key`
                                     });

        this.handleAfterReflex = () => {
            this.activeInteractions = true;
        }

        this.handleBeforeReflex = () => {
            this.activeInteractions = false;
        };

        document.addEventListener("stimulus-reflex:after", this.handleAfterReflex, false);
        document.addEventListener("stimulus-reflex:before", this.handleBeforeReflex, false);
    }

    disconnect() {
        document.removeEventListener("stimulus-reflex:after", this.handleAfterReflex, false);
        document.removeEventListener("stimulus-reflex:before", this.handleBeforeReflex, false);
    }

    handleEventClick() {
        AnimateModule.animatePageHide();
    }

    handlePlaceClick() {
        AnimateModule.animatePageHide();
    }

    showEventDetails() {
        if (this.md.mobile()) {
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
        this.isSimilarLoading = true;
        this.stimulate("Event#show_similar", this.eventTarget, {
            show_similar_to: this.identifier,
            in_this_section: this.sectionIdentifier
        })
            .then(payload => {
                this.activeInteractions       = true
                this.isSimilarLoading         = false;
                this.scrollToSimilarContainer = true;
            })
            .catch(payload => {

            })
    };

    openMenu() {
        const mdcMenu = new MDCMenu(this.menuTarget);
        mdcMenu.open  = !mdcMenu.open;
    };


    readMore() {
        this.data.set("description-open", true);
    }

    get limit() {
        return this.data.get("limit");
    }

    get isSimilarOpen() {
        return this.data.get("similarOpen");
    }

    set isSimilarOpen(value) {
        this.data.set("similar-open", value);
    }

    set isSimilarLoading(value) {
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

    set activeInteractions(value) {
        if (value) {
            if (this.hasOverlayTarget) {
                this.overlayRipple = new MDCRipple(this.overlayTarget);
            }
            if (this.hasLikeButtonTarget) {
                this.toggleLikeButton = new MDCIconButtonToggle(
                    this.likeButtonTarget
                );
            }
        } else {
            if (this.overlayRipple) {
                this.overlayRipple.destroy();
            }
            if (this.toggleLikeButton) {
                this.toggleLikeButton.destroy();
            }
        }
    }

    set scrollToSimilarContainer(value) {
        if (value) {

        }
    }

}
