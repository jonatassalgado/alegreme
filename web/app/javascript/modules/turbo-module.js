import * as Turbo from "@hotwired/turbo"

const TurboModule = (function () {
    const debug  = false;
    const module = {};
    const status = {
        turboStarted: false
    };

    module.backHistory = () => {
        try {
            let referrer = Turbo.navigator.currentVisit.referrer.absoluteURL;
            if (referrer) {
                window.history.back()
            } else {
                Turbo.visit('/')
            }
        } catch {
            Turbo.visit('/')
        }
    }

    module.startTurbo = () => {
        status.turboStarted = true;

        let scrollTop = 0
        let lastPage

        addEventListener("turbo:click", ({target}) => {
            if (target.hasAttribute("data-turbo-preserve-scroll")) {
                lastPage  = window.location.pathname
                scrollTop = document.scrollingElement.scrollTop
            }
        })

        addEventListener("turbo:render", () => {
            if (scrollTop && window.location.pathname === lastPage) {
                document.scrollingElement.scrollTo(0, scrollTop)
                // scrollTop = 0
            }
        })
        if (debug) console.log("[TURBOLINKS]: started");
    };


    window.TurboModule = module;
    window.Turbo       = Turbo;

    return module;
})();

export {TurboModule};
