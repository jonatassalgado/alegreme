import ApplicationController from "./application_controller"

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
        this.element.addEventListener("click", function (e) {
            const container = e.currentTarget;
            const ripple    = document.createElement("ripple");

            let x = e.pageX - container.offsetLeft;
            let y = e.pageY - container.offsetTop;

            ripple.className     = "_ripple";
            ripple.style.cssText = `left: ${x}px; top: ${y}px`;
            container.appendChild(ripple)

            setTimeout(() => {
                container.querySelector("._ripple").remove();
            }, 1000)
        });
    }

    teardown() {

    }
}
