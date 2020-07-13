import Flipping from "flipping";

const FlipperModule = (flipKey) => {
    const module   = {};
    const flipping = new Flipping({
                                      attribute: flipKey
                                  });

    console.log("[FLIP]: initied");

    module.read = () => {
        console.log("[FLIP]: read");
        flipping.read()
    };

    module.flip = () => {
        console.log("[FLIP]: flipping");
        flipping.flip();

        let delay   = 0.035;
        let counter = 0;
        let states  = Object.keys(flipping.states);

        states.forEach((key) => {
            counter++;

            const state = flipping.states[key];
            if (state.element === undefined) {
                return;
            }

            if (states.length > 48 && counter < (states.length - 8)) {
                return;
            }

            if (state.type === "MOVE" && state.delta) {
                state.element.style.transition = "";
                state.element.style.transform  = `translateY(${state.delta.top}px) translateX(${state.delta.left}px)`;
            }
            if (state.type === "ENTER") {
                state.element.style.opacity   = 0;
                state.element.style.transform = `scale(0.8)`;
            }
            requestAnimationFrame(() => {
                if (state.type === "MOVE" &&
                    state.delta) {
                    state.element.style.transition = `transform 0.6s cubic-bezier(.54,.01,.45,.99)`;
                    state.element.style.transform  = "";
                    state.element.style.opacity    = 1;
                }
                if (state.type === "ENTER") {
                    state.element.style.transition = `transform 0.4s cubic-bezier(0,.16,.45,.99) ${delay}s, opacity 0.4s cubic-bezier(0,.16,.45,.99) ${delay}s`;
                    state.element.style.transform  = "";
                    state.element.style.opacity    = 1;
                }
                delay = delay + 0.035;
            });
        });

        console.log("[FLIP]: flipped");
    };

    return module;
};

export {FlipperModule};


