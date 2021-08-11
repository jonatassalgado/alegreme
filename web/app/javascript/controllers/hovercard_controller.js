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
        this.timersHide = []
        this.timersShow = []

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
            this.clearTimerHide();
        }

        if (this.preserveValue && this.cardTarget?.innerHTML?.length > 0) {
            this.cardTarget.classList.remove("hidden", "opacity-0");
        } else {
            let timer = setTimeout(() => {
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
            }, 200)
            this.timersShow.push(timer)
        }
    }

    hide(event) {
        if (!this.activeValue) return

        this.clearTimerShow()

        requestAnimationFrame(() => {
            if (this.preserveValue && this.cardTarget?.innerHTML?.length > 0) {
                if (this.timerValue) {
                    let timer = setTimeout(() => {
                        this.cardTarget.classList.add("opacity-0");
                        setTimeout(() => {
                            this.cardTarget.classList.add("hidden");
                        }, 300)
                    }, this.timerValue)
                    this.timersHide.push(timer)
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
                this.timersHide.push(timer)
            }
        })
    }

    clearTimerShow() {
        if (this.timersShow?.length > 0) this.timersShow.forEach(timer => clearTimeout(timer))
    }

    clearTimerHide() {
        if (!this.activeValue) return

        if (this.timersHide?.length > 0) this.timersHide.forEach(timer => clearTimeout(timer))
    }


}
