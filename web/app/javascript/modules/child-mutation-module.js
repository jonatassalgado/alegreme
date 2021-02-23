const ChildMutation = (() => {
    const module     = {}
    const debug      = false
    let currentState = undefined

    if (debug) console.log("[CHILD MUTATION MODULE]: initied");

    module.read = (el) => {
        currentState = Array.from(el.children)
    }

    module.diff = (newState) => {
        return new Promise((resolve, reject) => {
            const elsChanged = Array.from(newState.children).filter((child) => {
                return !currentState.includes(child)
            })

            resolve(elsChanged)
        })
    };

    return module;
})();

export {ChildMutation};