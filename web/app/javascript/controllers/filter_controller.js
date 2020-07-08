import ApplicationController from "./application_controller"
import {MDCChipSet}          from "@material/chips";

export default class FilterController extends ApplicationController {
    static targets = ["chipset", "container", "chip", "input", "inputContainer"];

    connect() {
        super.connect();
        this.MDCChipSet = new MDCChipSet(this.chipsetTarget);
    }

    disconnect() {
        this.MDCChipSet.destroy();
    }

    async select(event) {
        const selectedChips = this.MDCChipSet.selectedChipIds.map((chipId, i) => {
            return this.chipsetTarget.querySelector(`#${chipId}`).dataset.filterValue;
        })

        this.stimulate("Event#update_collection", event.target, {
            filter: {
                type:  this.data.get("type"),
                value: await selectedChips
            }
        })
    }

}
