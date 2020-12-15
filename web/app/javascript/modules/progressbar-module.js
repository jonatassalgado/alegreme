import Turbolinks from "turbolinks"

const ProgressBarModule = (() => {
    const module = {};
    const debug  = false;

    const progressBar = new Turbolinks.ProgressBar();

    if (debug) console.log("[PROGRESSBAR]: initied");

    module.show = () => {
        progressBar.setValue(0);
        progressBar.show();
    };

    module.hide = () => {
        setTimeout(() => {
            progressBar.setValue(1);
            setTimeout(() => {
                progressBar.hide();
            }, 100);
        }, 250);
    };

    return module;
})();

export {ProgressBarModule};


