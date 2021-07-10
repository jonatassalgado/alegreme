import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = []
    static values  = {
        url: String
    }

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {

    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    scrollTo(event) {
        event.preventDefault()
        event.stopPropagation()
        const anchorEl = document.querySelector(`${this.urlValue}`);
        if (anchorEl) {
            const scrollTo = anchorEl.getBoundingClientRect().top + window.pageYOffset - 100
            window.scrollTo({
                                top:      scrollTo,
                                behavior: 'smooth'
                            })
        }
    }
}
