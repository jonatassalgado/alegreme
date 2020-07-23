import ApplicationController from "./application_controller"
import {debounce}            from "../utilities";

export default class HeadController extends ApplicationController {
    static targets = ["head", "tabBar", "backButton", "backButtonRipple"];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {
        if (this.hasHeadTarget) {
            this.lastScrollTop = 0;

            window.addEventListener("scroll", debounce(this.animateHeadOnScroll.bind(this)), {
                capture: false,
                passive: true
            });
        }
    }

    teardown() {
        window.removeEventListener("scroll", this.animateHeadOnScroll.bind(this));
    }

    animateHeadOnScroll() {
        if (!this.hasTabBarTarget) return;
        let currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
        requestIdleCallback(() => {
            if (window.scrollY > 5) {
                requestAnimationFrame(() => {
                    this.headTarget.classList.add("elevation-4");
                });
            } else {
                requestAnimationFrame(() => {
                    this.headTarget.classList.remove("elevation-4");
                });
            }

            if (window.scrollY > 50) {
                const transformY = this.element.offsetHeight - 46;
                if (currentScrollTop > this.lastScrollTop) {
                    requestAnimationFrame(() => {
                        this.headTarget.style.transform = `translateY(-${transformY}px)`;
                    });
                } else {
                    requestAnimationFrame(() => {
                        this.headTarget.style.transform = "translateY(0)"
                    });
                }
            } else {
                requestAnimationFrame(() => {
                    this.headTarget.style.transform = "translateY(0)"
                });
            }
            this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
        })
    }

}
