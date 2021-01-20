import * as Turbo from "@hotwired/turbo"

const CacheModule = (function () {
    const debug  = false;
    const module = {};
    const status = {
        turboStarted: false
    };

    module.startTurbo = () => {
        status.turboStarted = true;

        let scrollTop = 0
        let lastPage  = window.location.href

        addEventListener("turbo:click", ({target}) => {
            if (target.hasAttribute("data-turbo-preserve-scroll")) {
                scrollTop = document.scrollingElement.scrollTop
            }
        })

        addEventListener("turbo:load", () => {
            if (scrollTop && (window.location.href === lastPage)) {
                document.scrollingElement.scrollTo(0, scrollTop)
                scrollTop = 0
            }
        })

        if (debug) console.log("[TURBOLINKS]: started");
    };


    window.CacheModule = module;
    window.Turbo       = Turbo;

    return module;
})();

export {CacheModule};
