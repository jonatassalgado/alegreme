import * as MobileDetect from "mobile-detect";

const MobileDetector = (() => {
    const module = {};
    const md     = new MobileDetect(window.navigator.userAgent);

    console.log("[MOBILE DETECTOR]: initied");

    module.mobile = () => {
        md.mobile()
    };

    return module;
})();

export {MobileDetector};


