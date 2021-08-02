import ApplicationController from "./application_controller"
import {MobileDetector}      from "../modules/mobile-detector-module";

export default class extends ApplicationController {
    static targets = ['card'];
    static values  = {
        url:            String,
        position:       String,
        preserve:       Boolean,
        hideMouseenter: Boolean,
        timer:          Number,
        active:         Boolean
    };

    initialize() {
        this.timers = []

        if (this.positionValue == null) this.positionValue = 'append'
        if (this.preserveValue == null) this.preserveValue = true
        if (this.hideMouseenterValue == null) this.hideMouseenterValue = false
        if (this.activeValue == null) this.activeValue = false
    }

    connect() {
        super.connect()
        this.setup()
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

    }

    teardown() {
        if (this.hasCardTarget) {
            this.cardTargets.forEach(el => el.remove())
        }
    }

    show(event) {
        if (!this.activeValue) return

        const currentTarget = event.currentTarget

        if (MobileDetector.mobile() && event.type === 'click') {
            event.preventDefault()
        } else {
            this.clearTimer();
        }

        if (this.preserveValue && this.hasCardTarget) {
            this.cardTarget.classList.remove("hidden");
        } else {
            fetch(currentTarget.dataset.url)
                .then((r) => r.text())
                .then((html) => {
                    const fragment = document
                        .createRange()
                        .createContextualFragment(html);
                    requestAnimationFrame(() => {
                        setTimeout(() => {
                            if (this.hideMouseenterValue) {
                                this.cardTargets?.forEach(el => el.remove())
                            }

                            if (this.positionValue === 'prepend') {
                                this.element.prepend(fragment);
                            } else {
                                this.element.appendChild(fragment);
                            }
                        }, 310)
                    })
                });
        }
    }

    hide(event) {
        if (!this.activeValue) return

        if (this.preserveValue && this.hasCardTarget) {
            requestAnimationFrame(() => {
                this.cardTarget.classList.add("opacity-0");
                setTimeout(() => {
                    this.cardTarget.classList.add("hidden");
                }, 300)
            })
        }

        if (!MobileDetector.mobile() && !event.type === 'click' && this.timerValue) {
            let timer = setTimeout(() => {
                requestAnimationFrame(() => {
                    this.cardTargets?.forEach(card => card.classList.add("opacity-0"))
                    setTimeout(() => {
                        this.cardTargets?.forEach(el => el.remove())
                    }, 300)
                })
            }, this.timerValue)
            this.timers.append(timer)
        } else {
            this.cardTargets?.forEach(card => card.classList.add("opacity-0"))
            setTimeout(() => {
                this.cardTargets?.forEach(el => el.remove())
            }, 300)
        }
    }

    clearTimer() {
        if (!this.activeValue) return

        if (this.timers?.length > 0) this.timers.forEach(timer => clearTimeout(timer))
    }


}
