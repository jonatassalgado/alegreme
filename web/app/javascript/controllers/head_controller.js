import ApplicationController from "./application_controller"
import {MDCRipple}           from "@material/ripple";

export default class HeadController extends ApplicationController {
    static targets = ["head", "backButton", "backButtonRipple"];

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

            if (this.hasBackButtonRippleTarget) {
                this.backButtonRipple = new MDCRipple(this.backButtonRippleTarget);
            }

            window.addEventListener("scroll", this.animateHeadOnScroll.bind(this), {
                capture: false,
                passive: true
            });
        }
    }

    teardown() {
        if (this.hasBackButtonRippleTarget) {
            this.backButtonRipple.destroy();
        }
        window.removeEventListener("scroll", this.animateHeadOnScroll.bind(this));
    }

    animateHeadOnScroll() {
        var currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;

        if (window.scrollY > 5) {
            requestAnimationFrame(() => {
                this.headTarget.classList.add("me-head--with-shadow");
            });
        } else {
            requestAnimationFrame(() => {
                this.headTarget.classList.remove("me-head--with-shadow");
            });
        }

        if (window.scrollY > 250) {
            if (currentScrollTop > this.lastScrollTop) {
                requestAnimationFrame(() => {
                    this.headTarget.style.transform = "translateY(-56px)";
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
    }

}
