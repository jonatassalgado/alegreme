import ApplicationController from "./application_controller"
import {PubSubModule}        from "../modules/pubsub-module";

export default class ToggleLoaderController extends ApplicationController {
    static targets = ["on", "off", "onIcon"];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
        // this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    setup() {
        this.pubsub     = {};
        this.pubsub.on  = PubSubModule.on(this.listenerOn, (data) => {
            this._turnOn();
        });
        this.pubsub.off = PubSubModule.on(this.listenerOff, (data) => {
            this._turnOff();
        });
    }

    teardown() {
        PubSubModule.destroy(this.pubsub);
    }

    toggle(event) {
        if (!this.listenerOn) {
            this._turnOn();
        }
    }

    _turnOn() {
        this.onTarget.classList.remove("hidden")
        this.onIconTarget.classList.add("animation-1s", "animation-linear", "animation-spin")
        this.offTarget.classList.add("hidden")
    }

    _turnOff() {
        this.onTarget.classList.add("hidden")
        this.onIconTarget.classList.remove("animation-1s", "animation-linear", "animation-spin")
        this.offTarget.classList.remove("hidden")
    }

    get listenerOn() {
        return this.data.get("listenerOn");
    }

    get listenerOff() {
        return this.data.get("listenerOff");
    }
}
