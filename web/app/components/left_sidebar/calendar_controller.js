import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = ['loadingIcon', 'table', 'list', 'events'];

    async initialize() {
        const FlippingWeb = await import('flipping/lib/adapters/web');
        const selfEl      = this.element;
        this.flipping     = new FlippingWeb.default;

        this.element.addEventListener("cable-ready:before-morph", event => {
            if (this.hasEventsTarget) {
                // ChildMutation.read(this.eventsTarget)
                this.flipping.read()
            }
        })

        this.element.addEventListener("cable-ready:after-morph", event => {
            if (this.hasEventsTarget) {
                requestAnimationFrame(() => {
                    this.flipping.flip()
                    // ChildMutation.diff(this.eventsTarget)
                    //              .then(els => {
                    //                  els.forEach(el => el.classList.add("animate-added"))
                    //              })
                })
            }
        })

        document.addEventListener("horizontal-event#open-event:before", event => {
            selfEl.classList.add("opacity-0")
        }, false)

        document.addEventListener("horizontal-event#close-event:after", event => {
            setTimeout(() => {
                selfEl.classList.remove("opacity-0")
            }, 500)
        }, false)

        document.addEventListener("feed#load-more:loaded", event => {
            this.stickySidebar.updateSticky()
        }, false)
    }

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {
        await import('./calendar_component.scss')
        const StickySidebar = await import("sticky-sidebar/dist/sticky-sidebar")

        this.stickySidebar = new StickySidebar.default('#left-sidebar', {
            containerSelector:    '#main-content',
            innerWrapperSelector: '#calendar',
            topSpacing:           70,
            bottomSpacing:        300
        });

        document.addEventListener('sign-in#close', () => {
            this._cleanLoadingAnimate()
        }, false)
    }

    teardown() {
        this.stickySidebar.destroy()

        document.removeEventListener('sign-in#close', () => {
            this._cleanLoadingAnimate()
        }, false)

        document.removeEventListener("horizontal-event#open-event:before", event => {
            selfEl.classList.add("opacity-0")
        }, false)

        document.removeEventListener("horizontal-event#close-event:after", event => {
            setTimeout(() => {
                selfEl.classList.remove("opacity-0")
            }, 500)
        }, false)

        document.removeEventListener("feed#load-more:loaded", event => {
            this.stickySidebar.updateSticky()
        }, false)
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    beforePrevMonth() {
        this._loadingAnimate()
    }

    beforeNextMonth() {
        this._loadingAnimate()
    }

    beforeInDay(anchorElement) {
        this._loadingAnimate()
        // const dateGroup = document.querySelector(`#main-sidebar--group-${anchorElement.dataset.day}`);
        // if (dateGroup) {
        //     const scrollTo  = dateGroup.getBoundingClientRect().top + window.pageYOffset - 150
        //     window.scrollTo({
        //                         top:      scrollTo,
        //                         behavior: 'smooth'
        //                     })
        // }
    }

    inDay(event) {
        const target = event.target.closest('td');

        if (target.classList.contains('filter')) {
            this.stimulate('LeftSidebar::Calendar#clear_filter', target, {resolveLate: true})
                .then(payload => {

                })
                .catch(payload => {

                })
        } else {
            this.stimulate('LeftSidebar::Calendar#in_day', target, {resolveLate: true})
        }
    }

    beforeClearFilter(anchorElement) {
        this._loadingAnimate()
    }

    _cleanLoadingAnimate() {
        this.loadingIconTarget.classList.add("opacity-0")
        this.loadingIconTarget.classList.remove("animate-spin")
        this.tableTarget.classList.remove("animate-pulse")
        this.listTarget.classList.remove("animate-pulse")
    }

    _loadingAnimate() {
        this.loadingIconTarget.classList.remove("opacity-0")
        this.loadingIconTarget.classList.add("animate-spin")
        this.tableTarget.classList.add("animate-pulse")
        this.listTarget.classList.add("animate-pulse")
    }

}
