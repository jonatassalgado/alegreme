const Transition = (() => {
    const module = {};
    const debug  = false;

    if (debug) console.log("[TRANSITION MODULE]: initied");

    module.to = (el = Node, {
        transition = Function,
        observed = '',
        resetState = false,
        duration = 1000,
        rejectTime = 1500
    }) => {
        return new Promise((resolve, reject) => {
            let hasChanged = false;

            const observer = new MutationObserver((mutationsList, observer) => {
                for (const mutation of mutationsList) {
                    if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
                        if (observed.every((className) => {
                            return mutation.target.classList.contains(className)
                        })) {
                            hasChanged = true;
                            observer.disconnect();
                            setTimeout(() => {
                                if (resetState) observed.forEach((className) => {
                                    el.classList.remove(className)
                                })
                                resolve(el);
                            }, duration)
                        }
                    }
                }

                if (rejectTime > 0) {
                    window.setTimeout(() => {
                        if (!hasChanged) {
                            reject(el);
                        }
                    }, rejectTime);
                }
            });

            observer.observe(el, {
                attributes: true
            })

            requestAnimationFrame((rafId) => {
                transition()
            })
        })
    };

    return module;
})();

export {Transition};