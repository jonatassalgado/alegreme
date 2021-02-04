import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = ["loading", "loaded", "onIcon"];

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
        document.addEventListener(this.listenerOn, (e) => {
            this._loading();
        }, false);
        document.addEventListener(this.listenerOff, (e) => {
            this._loaded();
        }, false);
    }

    teardown() {
        document.removeEventListener(this.listenerOn, (e) => {
            this._loading();
        }, false);
        document.removeEventListener(this.listenerOff, (e) => {
            this._loaded();
        }, false);
    }

    toggle(event) {
        if (!this.listenerOn) {
            this._loading();
        }
    }

    _loading() {
        if (this.hasLoadingTarget) this.loadingTarget.classList.remove("hidden")
        if (this.hasOnIconTarget) this.onIconTarget.classList.add("animation-1s", "animation-linear", "animation-spin")
        if (this.hasLoadedTarget) this.loadedTarget.classList.add("hidden")
    }

    _loaded() {
        if (this.hasLoadingTarget) this.loadingTarget.classList.add("hidden")
        if (this.hasOnIconTarget) this.onIconTarget.classList.remove("animation-1s", "animation-linear", "animation-spin")
        if (this.hasLoadedTarget) this.loadedTarget.classList.remove("hidden")
    }

    get listenerOn() {
        return this.data.get("onLoading");
    }

    get listenerOff() {
        return this.data.get("onLoaded");
    }
}
