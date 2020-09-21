import ApplicationController from "./application_controller"
import {debounce}            from "../utilities";

export default class BottomNavigationController extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        // this.setup();
    }

    beforeCache() {
        // super.beforeCache();
        // this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {
        this.lastScrollTop = 0;

        window.addEventListener("scroll", debounce(this.animateNavigationOnScroll.bind(this)), {
            capture: false,
            passive: true
        });
    }

    teardown() {
        window.removeEventListener("scroll", this.animateNavigationOnScroll.bind(this));
    }

    animateNavigationOnScroll() {
        var currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
        requestIdleCallback(() => {
            if (window.scrollY > 50) {
                if (currentScrollTop > this.lastScrollTop) {
                    requestAnimationFrame(() => {
                        this.element.style.transform = "translateY(60px)"
                    });
                } else {
                    requestAnimationFrame(() => {
                        this.element.style.transform = "translateY(0)"
                    });
                }
            } else {
                requestAnimationFrame(() => {
                    this.element.style.transform = "translateY(0)"
                });
            }
            this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
        })
    }
}
