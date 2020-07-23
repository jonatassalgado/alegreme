import ApplicationController from "./application_controller"
import {ProgressBarModule}   from "../modules/progressbar-module";
import {PubSubModule}        from "../modules/pubsub-module";

export default class FilterController extends ApplicationController {
    static targets = ["chipset", "chip", "input"];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        this.teardown();
    }

    setup() {
        this.urlParams = new URLSearchParams(window.location.search)
        this.filters   = {}
        this.initSelect();
        this.updateStyle();
    }

    teardown() {
        // this.MDCChipSet.destroy();
    }

    select(event) {
        ProgressBarModule.show();
        PubSubModule.emit("filter#select->started");

        this.toggleChip(event.currentTarget);
        this.updateChipsAttrs(event.currentTarget);
        this.updateFilterValue(event.currentTarget);
        this.updateStyle();
        this.updateUrlParams();

        this.stimulate("Event#update_collection", event.currentTarget, {
            filters: this.filters
        }).then(data => {
            PubSubModule.emit("filter#select->finished")
            this.replaceUrlParams();
            ProgressBarModule.hide();
        })
    }

    replaceUrlParams() {
        if (this.urlParams.toString().length > 0) {
            window.history.replaceState({}, "", `${window.location.pathname}?${this.urlParams}`);
        } else {
            window.history.replaceState({}, "", `${window.location.pathname}`);
        }
    }

    updateUrlParams() {
        Object.entries(this.filters).forEach(filter => {
            if (filter[1].length > 0) {
                this.urlParams.set(filter[0], JSON.stringify(filter[1]))
            } else {
                this.urlParams.delete(filter[0])
            }
        })
    }

    updateChipsAttrs(currentTarget) {
        Array.from(this.chipTargets).filter(chip => {
            return chip.dataset.chipType ===
                currentTarget.dataset.chipType &&
                chip.dataset.chipValue !==
                currentTarget.dataset.chipValue
        }).forEach(chip => {
            chip.dataset.chipSelected = "false"
        })
    }

    updateFilterValue(currentTarget) {
        if (currentTarget.dataset.chipSelected === "true") {
            this.filters[currentTarget.dataset.chipType] = [currentTarget.dataset.chipValue]
        } else {
            this.filters[currentTarget.dataset.chipType] = []
        }
    }

    toggleChip(currentTarget) {
        currentTarget.dataset.chipSelected = !JSON.parse(currentTarget.dataset.chipSelected)
    }

    initSelect() {
        this.chipTargets.forEach(chip => {
            if (chip.dataset.chipSelected === "true") {
                this.filters[chip.dataset.chipType] = [chip.dataset.chipValue]
            }
        })
    }

    updateStyle() {
        this.chipTargets.forEach(chip => {
            this.inactiveClass.forEach(cl => chip.classList.toggle(cl, chip.dataset.chipSelected === "false"))
            this.activeClass.forEach(cl => chip.classList.toggle(cl, chip.dataset.chipSelected === "true"))
        })
    }

    get activeClass() {
        return JSON.parse(this.data.get("activeClass"));
    }

    get inactiveClass() {
        return JSON.parse(this.data.get("inactiveClass"));
    }

    get type() {
        return this.data.get("type")
    }
}
