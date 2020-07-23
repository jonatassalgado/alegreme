import ApplicationController from "./application_controller"

export default class GoToController extends ApplicationController {
    static targets = [];

    url(event) {
        const trigger = event.currentTarget;

        setTimeout(() => {
            Turbolinks.visit(trigger.dataset.goToUrl)
        }, this.delay)
    }


    get delay() {
        return parseInt(this.data.get("delay")) || 0;
    }
}
