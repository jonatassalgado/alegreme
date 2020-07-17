const MobileDetector = (() => {
    const module = {};

    console.log("[MOBILE DETECTOR]: initied");

    module.mobile = () => {
        return /Mobi/i.test(window.navigator.userAgent)
    };

    module.pwa = () => {
        return (window.matchMedia("(display-mode: standalone)").matches) ||
            (window.navigator.standalone) ||
            document.referrer.includes("android-app://")
    };

    return module;
})();

export {MobileDetector};


