const BotModule = (() => {
    const debug = false;

    const module = {};
    const timers = [];

    const createContainer = ({human, cssClass, delay, resolve}) => {
        const container = document.createElement("div");

        container.className       = `bot__container ${
            human ? "is-human" : "is-bot"
        } ${cssClass}`;
        container.style.opacity   = 0;
        container.style.transform = `translateX(${human ? "" : "-"}8%)`;

        timers.push(
            setTimeout(() => {
                if (!module.domNode) return
                module.domNode.appendChild(container);
            }, 50)
        )

        timers.push(
            setTimeout(() => {
                requestAnimationFrame(() => {
                    if (!module.domNode) return
                    container.style.opacity   = 1;
                    container.style.transform = "translateX(0)";
                    if (resolve) {
                        resolve(container);
                    }
                });
            }, delay || 100)
        )

        return container;
    }

    const scrollToEnd = () => {
        timers.push(
            setTimeout(() => {
                if (!module.domNode) return
                const onboardingEl = document.querySelector("[data-swipable-module=\"onboarding\"]");
                if (onboardingEl) onboardingEl.scrollTo({
                                                            top:      onboardingEl.scrollHeight,
                                                            behavior: "smooth"
                                                        })
            }, 300)
        )
    }

    module.init = (wrapper) => {
        if (debug) console.log("[BOT INITIED]")
        module.domNode = wrapper;
        module.domNode.classList.add("is-bot");
    }

    module.action = (obj) => {
        return module[`${obj.type}Action`](obj);
    }

    module.buttonAction = ({items, delay, human, cssClass}) => {
        return new Promise((resolve, reject) => {
            var container = createContainer({
                                                human,
                                                delay,
                                                cssClass: "no-icon"
                                            });

            items.forEach(item => {
                const button     = document.createElement("div");
                button.className = `${item.cssClass} cursor-pointer tap-highlight-none select-none float-right bg-green-500 px-4 py-2 rounded-full text-white antialiased font-semibold`;
                button.innerHTML = item.text;
                button.addEventListener("click", () => {
                    resolve(item.value);
                    container.style.opacity = 0;
                    timers.push(setTimeout(() => module.domNode.removeChild(container), 300))
                }, {once: true});
                container.appendChild(button);
                scrollToEnd();
            });

        });
    }

    module.message = ({content, cssClass, delay, human}) => {
        return new Promise((resolve, reject) => {
            let container = createContainer({
                                                human,
                                                cssClass,
                                                delay,
                                                resolve
                                            });

            let message       = document.createElement("div");
            message.className = `antialiased bg-gray-100 inline-flex is-bot px-4 py-3 rounded-xl text-sm text-gray-600 leading-tight ${human ? "is-human" : "is-bot"}`;

            requestAnimationFrame(() => {
                message.innerHTML = content;
                container.appendChild(message);

                scrollToEnd();
            });
        });
    }

    module.destroy = () => {
        if (module.domNode) {
            module.domNode.innerHTML = "";
            module.domNode           = null;
        }
        if (timers.length > 0) {
            timers.forEach((timer) => {
                clearTimeout(timer)
            })
        }
    }

    return module;
})();

export {BotModule};
