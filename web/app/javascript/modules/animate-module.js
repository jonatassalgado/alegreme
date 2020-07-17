import {MobileDetector} from "./mobile-detector-module";

const AnimateModule = (function () {
    const debug  = false;
    const module = {};

    module.init = () => {
        document.addEventListener("turbolinks:load", module.animateOpenPage);
        if (debug) console.log("[ANIMATE]: started");
    };

    module.animateOpenPage = () => {
        const page = document.querySelector(".me-page.is-animated");

        if (MobileDetector.mobile()) {
            if (debug) console.log("[ANIMATE]: animate page");

            if (page) {
                page.style.opacity   = 0;
                page.style.transform = "translate(0, 24px)"

                requestAnimationFrame(() => {
                    page.style.opacity   = 1;
                    page.style.transform = ""
                });
            }
            document.addEventListener("turbolinks:before-cache", () => {
                const page = document.querySelector(".me-page.is-animated");
                if (page) {
                    page.style.opacity   = 0;
                    page.style.transform = "translate(0, 24px)"
                }
            }, {
                                          once: true
                                      });
        }
    };

    module.animatePageHide = () => {
        const page = document.querySelector(".me-page.is-animated");

        if (MobileDetector.mobile()) {
            if (debug) console.log("[ANIMATE]: page hide");

            if (page) {
                page.style.opacity = 1;
                // page.style.transform = ""

                requestAnimationFrame(() => {
                    page.style.opacity = 0;
                    // page.style.transform = "scale(0.95)"
                });
            }
        }
    };

    module.animateBackbutton = () => {
        const page = document.querySelector(".me-page.is-animated");

        if (MobileDetector.mobile()) {
            if (debug) console.log("[ANIMATE]: backbutton");

            if (page) {
                requestAnimationFrame(() => {
                    page.style.opacity   = 0;
                    page.style.transform = "translate(0, 24px)"
                });
            }
        }

        setTimeout(() => {
            window.history.back();
        }, 25)
    };

    window.AnimateModule = module;

    return module;
})();

export {AnimateModule};
