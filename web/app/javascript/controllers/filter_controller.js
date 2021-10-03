import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = ['loadingIcon', 'filters', 'modal'];

    static values = {
        loading: Boolean
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

    open() {
        if (this.hasModalTarget) this.modalTarget.classList.remove('hidden')
    }

    close() {
        if (this.hasModalTarget) this.modalTarget.classList.add('hidden')
    }

    clear() {
        document.querySelector('#main-sidebar--feed').src = '/'
    }

    loading() {
        this._startAnimate()
    }

    loaded() {
        this._endAnimate()
        document.dispatchEvent(new Event('feed#load-more:loaded'))
    }

    _startAnimate() {
        this.loadingValue = true
        // document.dispatchEvent(new Event('filter#filtering:start'))
        Array.from(this.filtersTargets).forEach(filter => {
            filter.classList.add("opacity-50", "pointer-events-none")
        })
        setTimeout(() => {
            if (this.hasLoadingIconTarget && this.loadingValue) {
                this.loadingIconTarget.classList.remove("opacity-0")
                this.loadingIconTarget.classList.add("animate-spin")
            }
        }, 250)
    }

    _endAnimate() {
        if (this.hasFiltersTarget) {
            Array.from(this.filtersTargets).forEach(filter => {
                filter.classList.remove("opacity-50", "pointer-events-none")
            })
        }
        if (this.hasLoadingIconTarget) {
            this.loadingIconTarget.classList.add("opacity-0")
            setTimeout(() => {
                this.loadingIconTarget.classList.remove("animate-spin")
            }, 250)
        }
        this.loadingValue = false
        // document.dispatchEvent(new Event('filter#filtering:end'))
    }

}
