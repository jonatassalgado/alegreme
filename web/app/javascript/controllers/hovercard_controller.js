import ApplicationController from "./application_controller"
import {MobileDetector}      from "../modules/mobile-detector-module";

export default class extends ApplicationController {
    static targets = ['card', 'inner'];
    static values  = {
        url:            String,
        preserve:       Boolean,
        hideMouseenter: Boolean,
        timer:          Number,
        active:         Boolean
    };

    initialize() {
        this.timers = []

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
            this.cardTarget.innerHTML = ""
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

        if (this.preserveValue && this.cardTarget?.innerHTML?.length > 0) {
            this.cardTarget.classList.remove("hidden", "opacity-0");
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
                                this.cardTarget.innerHTML = ""
                            }
                            this.cardTarget.appendChild(fragment)
                            this.cardTarget.classList.remove("hidden", "opacity-0");
                        }, 310)
                    })
                });
        }
    }

    hide(event) {
        if (!this.activeValue) return

        requestAnimationFrame(() => {
            if (this.preserveValue && this.cardTarget?.innerHTML?.length > 0) {
                if (this.timerValue) {
                    let timer = setTimeout(() => {
                        this.cardTarget.classList.add("opacity-0");
                        setTimeout(() => {
                            this.cardTarget.classList.add("hidden");
                        }, 300)
                    }, this.timerValue)
                    this.timers.push(timer)
                } else {
                    this.cardTarget.classList.add("opacity-0");
                    setTimeout(() => {
                        this.cardTarget.classList.add("hidden");
                    }, 300)
                }
            } else if (MobileDetector.mobile() && event.type === 'click') {
                this.innerTargets?.forEach(card => card.classList.add("opacity-0", "translate-y-10"))
                setTimeout(() => {
                    this.cardTarget.innerHTML = ""
                }, 500)
            } else if (event.type !== 'click' && this.timerValue) {
                let timer = setTimeout(() => {
                    this.cardTarget.classList.add("opacity-0")
                    setTimeout(() => {
                        this.cardTarget.innerHTML = ""
                    }, 300)

                }, this.timerValue)
                this.timers.push(timer)
            }
        })
    }

    clearTimer() {
        if (!this.activeValue) return

        if (this.timers?.length > 0) this.timers.forEach(timer => clearTimeout(timer))
    }


}
