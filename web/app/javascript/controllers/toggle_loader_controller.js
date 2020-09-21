import ApplicationController from "./application_controller"

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
        this.element.addEventListener(this.listenerOn, (e) => {
            this._turnOn();
        }, false);
        this.element.addEventListener(this.listenerOff, (e) => {
            this._turnOff();
        }, false);
    }

    teardown() {
        // this.element.removeEventListener(this.listenerOn);
        // this.element.removeEventListener(this.listenerOff);
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
