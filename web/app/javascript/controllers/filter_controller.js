import ApplicationController from "./application_controller"
import {MDCChipSet}          from "@material/chips";
import {ProgressBarModule}   from "../modules/progressbar-module";

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
        ProgressBarModule.show();

        event.target.addEventListener("MDCChip:selection", (selectionEvent) => {
            let selected    = selectionEvent.detail.selected;
            let filterValue = selectionEvent.target.dataset.filterValue;
            let value       = selected ? [filterValue] : [];
            let type        = this.type;

            this.stimulate("Event#update_collection", selectionEvent.target, {
                filter: {
                    type:  type,
                    value: value
                }
            })
                .then(() => {
                    ProgressBarModule.hide();
                })
        }, {once: true})
    }

    get type() {
        return this.data.get("type")
    }
}
