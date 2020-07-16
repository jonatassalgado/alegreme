import ApplicationController from "./application_controller"
import {FlipperModule}       from "../modules/flipper-module";

export default class SavesController extends ApplicationController {
    static targets = ["saves", "list", "title", "date", "remove", "scrollLeft", "scrollRight", "header"];

    connect() {
        this.pubsub  = {};
        this.flipper = FlipperModule(`data-collection-${this.id}-flip-key`);

        this.activeFlip();

        if (this.hasListTarget) {
            this.scrollLeftEvent  = new CustomEvent("scrolledLeft", {"detail": {"controller": this}});
            this.scrollRightEvent = new CustomEvent("scrolledRight", {"detail": {"controller": this}});

            this.updateScrollButtonsStatus();
            this.removeRepeatedDates();
        }

        if (this.hasListTarget) {
            this.listTarget.addEventListener("scrolledLeft", SavesController.scrolledToLeft);
            this.listTarget.addEventListener("scrolledRight", SavesController.scrolledToRight);
        }
    }

    disconnect() {
        this.pubsub.savesUpdate();
        this.flipper.destroy();
        if (this.hasListTarget) {
            delete this.scrollLeftEvent;
            delete this.scrollRightEvent;
        }
    }

    activeFlip() {
        this.pubsub.savesUpdate = PubSubModule.on("save-button.clicked", (data) => {
            this.flipper.read()
            document.addEventListener("cable-ready:after-morph", this.flipper.flip, {once: true});
        });
    }

    scrollLeft(event) {
        const amount = this.listTarget.offsetWidth * -1;
        this.listTarget.scrollBy(amount, 0);
        setTimeout(() => {
            this.listTarget.dispatchEvent(this.scrollLeftEvent)
        }, 350);
    }


    scrollRight(event) {
        const amount = this.listTarget.offsetWidth;
        this.listTarget.scrollBy(amount, 0);
        setTimeout(() => {
            this.listTarget.dispatchEvent(this.scrollRightEvent)
        }, 350);
    }

    static scrolledToLeft(event) {
        event.detail.controller.updateScrollButtonsStatus()
    }

    static scrolledToRight(event) {
        event.detail.controller.updateScrollButtonsStatus()
    }

    updateScrollButtonsStatus() {
        if (this.hasListTarget) {
            requestAnimationFrame(() => {
                var containerSize      = this.listTarget.offsetParent.offsetWidth;
                var scrollSizeOverflow = this.listTarget.scrollWidth;
                var scrolled           = this.listTarget.scrollLeft;

                const scrollUntilX         = () => containerSize + scrolled;
                const scrolledUntilEnd     = () => scrollUntilX() === scrollSizeOverflow;
                const hasToScroll          = () => containerSize < scrollSizeOverflow;
                const hasToScrollYet       = () => scrollUntilX() < scrollSizeOverflow;
                const scrollInZeroPosition = () => scrolled === 0;

                const switchLeftButton = (turnOn = true) => {
                    if (turnOn) {
                        this.scrollLeftTarget.classList.remove("me-icon--off");
                        this.listTarget.classList.remove("me-saves__list--at-end");
                        this.listTarget.classList.add("me-saves__list--at-initital");
                    } else {
                        this.scrollLeftTarget.classList.add("me-icon--off");
                        this.listTarget.classList.remove("me-saves__list--at-initital");
                    }
                };

                const switchRightButton = (turnOn = true) => {
                    if (turnOn) {
                        this.scrollRightTarget.classList.remove("me-icon--off");
                        this.listTarget.classList.add("me-saves__list--at-end");
                        this.listTarget.classList.remove("me-saves__list--at-initital");
                    } else {
                        this.scrollRightTarget.classList.add("me-icon--off");
                        this.listTarget.classList.remove("me-saves__list--at-end");
                    }

                };

                if (scrollInZeroPosition() && scrolledUntilEnd()) {
                    switchLeftButton(false);
                    switchRightButton(false)
                } else if (scrolledUntilEnd() && hasToScroll()) {
                    switchLeftButton();
                    switchRightButton(false)
                } else if (scrollInZeroPosition() && hasToScrollYet()) {
                    switchRightButton();
                    switchLeftButton(false)
                } else if (hasToScrollYet() && !scrolledUntilEnd() && !scrollInZeroPosition()) {
                    switchLeftButton();
                    switchRightButton()
                }
            });
        }
    }


    removeRepeatedDates() {
        if (this.hasListTarget) {
            requestIdleCallback(() => {
                const dates = document.querySelectorAll(".me-saves .me-card__date");
                if (dates.length > 0) {
                    var lastDay = dates[0].innerText;
                    for (var i = 0; i < dates.length - 1; i++) {
                        if (lastDay !== dates[i + 1].innerText) {
                            lastDay = dates[i].innerText;
                        }
                        if (lastDay === dates[i + 1].innerText) {
                            dates[i + 1].innerHTML = "";
                        }
                    }
                }
            }, {timeout: 250});
        }
    }

    get id() {
        return this.savesTarget.id
    }

}
