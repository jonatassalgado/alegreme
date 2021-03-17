import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {
        document.addEventListener('filter#filtering:start', () => {
            requestAnimationFrame(() => {
                this.element.classList.add('animate-pulse')
            })
        }, false)

        document.addEventListener('filter#filtering:end', () => {
            requestAnimationFrame(() => {
                this.element.classList.remove('animate-pulse')
                const scrollTo = this.element.getBoundingClientRect().top + window.pageYOffset - 160
                window.scrollTo({
                                    top:      scrollTo,
                                    behavior: 'smooth'
                                })
            })
        }, false)
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

}
