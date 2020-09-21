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