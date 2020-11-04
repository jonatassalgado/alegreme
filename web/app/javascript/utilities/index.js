export const debounce = (callback, delay = 250) => {
    let timeoutId
    return (...args) => {
        clearTimeout(timeoutId)
        timeoutId = setTimeout(() => {
            timeoutId = null
            callback(...args)
        }, delay)
    }
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
        if (el) {resolve(el);}
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
            subtree: true
        });
    });
}