import ApplicationController from "./application_controller"

export default class ScrollOnClickedController extends ApplicationController {
    static targets = ["scroller", "item"];

    connect() {
        super.connect();
        if (this.hasItemTarget && this.hasScrollerTarget) {
            const initSelectedEl = this.itemTargets.find(item => {
                return item.dataset.scrollOnClickedSelected === this.initSelected
            })
            this._left(initSelectedEl, "auto")
        }
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        // this.teardown();
    }

    teardown() {
        if (this.hasItemTarget && this.hasScrollerTarget) {
            const initSelectedEl = this.itemTargets.find(item => {
                return item.dataset.scrollOnClickedSelected === this.initSelected
            })
            this._left(initSelectedEl, "auto")
        }
    }

    scroll(event) {
        this._left(event.currentTarget);
    }

    _left(currentTarget, behavior = "smooth") {
        if (!currentTarget) return;

        Array.from(this.itemTargets).filter(item => {
            return item !== currentTarget
        }).forEach(item => {
            item.dataset.scrollOnClickedSelected = false
        })

        this.scrollerTarget.scrollTo({
                                         left:     currentTarget.offsetLeft - this.offsetLeft,
                                         behavior: behavior
                                     })

        currentTarget.dataset.scrollOnClickedSelected = true
    }

    get initSelected() {
        return this.data.get("initSelected").trim();
    }

    get offsetLeft() {
        return parseInt(this.data.get("offsetLeft")) ?? 0;
    }

}
