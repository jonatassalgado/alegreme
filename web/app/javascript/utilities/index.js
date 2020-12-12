// https://github.com/component/debounce
export const debounce = (func, wait, immediate) => {
    var timeout, args, context, timestamp, result;
    if (null == wait) wait = 100;

    function later() {
        var last = Date.now() - timestamp;

        if (last < wait && last >= 0) {
            timeout = setTimeout(later, wait - last);
        } else {
            timeout = null;
            if (!immediate) {
                result  = func.apply(context, args);
                context = args = null;
            }
        }
    }

    var debounced = function () {
        context     = this;
        args        = arguments;
        timestamp   = Date.now();
        var callNow = immediate && !timeout;
        if (!timeout) timeout = setTimeout(later, wait);
        if (callNow) {
            result  = func.apply(context, args);
            context = args = null;
        }

        return result;
    }

    debounced.clear = function () {
        if (timeout) {
            clearTimeout(timeout);
            timeout = null;
        }
    }

    debounced.flush = function () {
        if (timeout) {
            result  = func.apply(context, args);
            context = args = null;

            clearTimeout(timeout);
            timeout = null;
        }
    }

    return debounced;
}

export const toSnakeCase = (string) => {
    return string.replace(/\W+/g, " ")
                 .split(/ |\B(?=[A-Z])/)
                 .map(word => word.toLowerCase())
                 .join('_');
}

export const elementReady = (selector) => {
    return new Promise((resolve, reject) => {
        const el = document.querySelector(selector);
        if (el) {
            resolve(el);
        }
        new MutationObserver((mutationRecords, observer) => {
            // Query for elements matching the specified selector
            Array.from(document.querySelectorAll(selector)).forEach((element) => {
                resolve(element);
                //Once we have resolved we don't need the observer anymore.
                observer.disconnect();
            });
        })
            .observe(document.documentElement, {
                childList: true,
                subtree:   true
            });
    });
}