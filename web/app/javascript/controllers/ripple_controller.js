import ApplicationController from "./application_controller"
import {MobileDetector}      from "../modules/mobile-detector-module";

export default class RippleController extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    setup() {
        this.evt = MobileDetector.mobile() ? "touchend" : "click";
        this.element.addEventListener(this.evt, this._showRipple, false)
    }

    teardown() {
        Array.from(document.querySelectorAll("._ripple")).forEach(el => {
            el.remove()
        });
        this.element.removeEventListener(this.evt, this._showRipple, false)
    }

    _showRipple(e) {
        e.stopPropagation();
        const container       = e.currentTarget;
        const ripple          = document.createElement("ripple");
        const containerRect   = container.getBoundingClientRect();
        const containerSquare = (container.offsetWidth + container.offsetHeight) / 2;
        const rippleSize      = (containerSquare / 8);
        const x               = (e.pageX || e.changedTouches[0].clientX) - containerRect.x;
        const y               = (e.pageY || e.changedTouches[0].clientY) - containerRect.y;

        ripple.className     = "_ripple";
        ripple.style.cssText = `
        left: ${x}px; 
        top: ${y}px; 
        width: ${rippleSize}px; 
        height: ${rippleSize}px;
        margin-top: -${rippleSize / 2}px;
        margin-left: -${rippleSize / 2}px
        `;

        container.appendChild(ripple)

        setTimeout(() => {
            container.querySelector("._ripple").remove();
        }, 1000)
    }

}
