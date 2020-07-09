import ApplicationController from "./application_controller"
import {MDCChipSet}          from "@material/chips";

export default class FilterController extends ApplicationController {
    static targets = ["chipset", "container", "chip", "input", "inputContainer"];

    connect() {
        super.connect();
        this.MDCChipSet = new MDCChipSet(this.chipsetTarget)
    }

    disconnect() {
        this.MDCChipSet.destroy();
    }

    select(event) {
        this.stimulate("Event#update_collection", event.target, {
            filter: {
                type:  this.data.get("type"),
                value: event.detail.selected ? [event.target.dataset.filterValue] : []
            }
        })
    }

}
