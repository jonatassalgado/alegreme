import ApplicationController from "./application_controller"
import {debounce}            from "../utilities";
import {MobileDetector}      from "../modules/mobile-detector-module";

export default class extends ApplicationController {
    static targets = ['button'];

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
        this.teardown()
    }

    setup() {
        if (!this._pwaInstalled() && MobileDetector.mobile() && !MobileDetector.pwa()) {
            this.deferredPrompt

            window.addEventListener('beforeinstallprompt', (e) => {
                e.preventDefault()
                this.deferredPrompt = e
            });
            window.addEventListener("scroll", debounce(this._showButton.bind(this)), {
                capture: false,
                passive: true
            });
        } else {
            this.element.classList.add('hidden')
        }
    }

    _pwaInstalled() {
        try {
            const storageContent = JSON.parse(localStorage.getItem('install_controller'))
            return storageContent.pwaInstalled
        } catch {
            return false
        }
    }

    teardown() {

    }

    install() {
        if (this.data.get('native')) {
            location.assign('https://play.google.com/store/apps/details?id=com.alegreme.app&referrer=utm_source%3Dwebsite')
            this._hideButton();
        } else {
            this.deferredPrompt.prompt()
            this._hideButton();
        }
    }

    _hideButton() {
        setTimeout(() => {
            this.element.classList.add('hidden')
            localStorage.setItem('install_controller', JSON.stringify({pwaInstalled: true}))
        }, 500)
    }

    _showButton() {
        if (!this.hasButtonTarget) return;
        let currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
        requestIdleCallback(() => {
            if (window.scrollY > 500) {
                if (currentScrollTop > this.lastScrollTop) {
                    requestAnimationFrame(() => {
                        this.element.classList.remove('translate-y-32')
                    });
                } else {
                    requestAnimationFrame(() => {
                        this.element.classList.add('translate-y-32')
                    });
                }
            } else {
                requestAnimationFrame(() => {
                    this.element.classList.add('translate-y-32')
                });
            }
            this.lastScrollTop = currentScrollTop <= 0 ? 0 : currentScrollTop;
        })
    }

}
