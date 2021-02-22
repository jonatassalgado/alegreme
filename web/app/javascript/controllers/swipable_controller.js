import ApplicationController from "./application_controller"

export default class SwipableController extends ApplicationController {
    static targets = ["onboarding", "items", "skip", "endMessage", "loadingOn", "loadingOff", "loadingIcon"];

    async connect() {
        const {BotModule} = await import("../modules/bot-module")

        this.bot = BotModule;

        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    setup() {
        if ((this.userSigninCount <= 1 && this.eventsLiked < 1)) {
            setTimeout(() => {
                this.showBot();
            }, 500)
        } else {
            if (this.element) {
                this.showSwipe();
                this.element.addEventListener("swipable#event->trained", this._onSwipableTrained(), false);
            }
        }
    }

    _onSwipableTrained(e) {
        return e => {
            this.eventsToTrain = this.eventsToTrain - 1;
            this.eventsLiked   = e.detail.eventsLiked;
            if (this.eventsToTrain === 0) {
                if (this.eventsLiked > 2) {
                    this.endMessageTarget.querySelector("#end-message-title").innerText = `Obrigado ${this.userName}! Com base nos ${this.eventsLiked} itens que você curtiu, já consigo te recomendar alguns eventos que você vai gostar.`;
                } else {
                    this.endMessageTarget.querySelector("#end-message-title").innerText = `Obrigado ${this.userName}! Como você curtiu poucos eventos tenho mais alguns para você classificar antes de te indicar algo.`;
                    this.loadingOffTarget.innerText = "Carregar mais eventos";
                }
                this.itemsTarget.classList.add("hidden");
                this.element.classList.add("align-middle", "flex");
                this.endMessageTarget.classList.remove("hidden", "opacity-0");
            }
        }
    }

    teardown() {
        this.bot.destroy();
        this.itemsTarget.classList.add("hidden", "opacity-0");
        this.onboardingTarget.classList.remove("hidden", "opacity-0");
        this.element.removeEventListener("swipable#event->trained", this._onSwipableTrained(), false);
    }

    showBot() {
        this.onboardingTarget.classList.remove("hidden", "opacity-0")

        this.bot.init(this.onboardingTarget)
        this.bot.message({
                             content: `Olá ${this.userName} 👋`,
                             delay:   150
                         }).then(ok =>
                                     this.bot.message({
                                                          cssClass: "no-icon",
                                                          content:
                                                                    "Vamos aproveitar a cidade de Porto Alegre juntos!",
                                                          delay:    2000
                                                      })
        ).then(ok =>
                   this.bot.message({
                                        cssClass: "no-icon",
                                        content:
                                                  "Inicialmente vamos te sugerir eventos, mas logo também iremos sugerir filmes no cinema, serviços, promoções e experiências",
                                        delay:    1500
                                    })).then(ok =>
                                                 this.bot.message({
                                                                      cssClass: "no-icon",
                                                                      content:
                                                                                "Chega de papo, vamos começar!",
                                                                      delay:    4000
                                                                  })
        ).then(ok =>
                   this.bot.message({
                                        cssClass: "no-icon",
                                        content:
                                                  "Para sugerir eventos que tem a ver com você, primeiro me diga o que você gosta e não gosta",
                                        delay:    1000
                                    })
        ).then(ok =>
                   this.bot.message({
                                        cssClass: "no-icon",
                                        content:  "Vamos lá?",
                                        delay:    4000
                                    })
        ).then(ok =>
                   this.bot.action({
                                       type:  "button",
                                       delay: 500,
                                       items: [
                                           {
                                               text:  "Vamos",
                                               value: "Vamos!"
                                           }
                                       ]
                                   })
        ).then(ok =>
                   this.bot.message({
                                        delay:   250,
                                        human:   true,
                                        content: ok
                                    })
        ).then(ok => {
            this.bot.message({
                                 content: "Carregando opções...",
                                 delay:   1500
                             })
        }).then(ok => {
            setTimeout(() => {
                requestAnimationFrame(() => {
                    this.onboardingTarget.classList.add("opacity-0");
                    setTimeout(() => {
                        if (this.element) {
                            this.showSwipe();
                        }
                    }, 450)

                });
            }, 4000);
        }).catch(error => console.log("error", error));
    }

    showSwipe() {
        this.onboardingTarget.classList.add("hidden", "opacity-0")
        this.itemsTarget.classList.remove("hidden", "opacity-0");
    }

    loadSuggestions() {
        this.loadingOffTarget.classList.add("hidden");
        this.loadingOnTarget.classList.remove("hidden");
        this.loadingIconTarget.classList.add("animate-spin");
    }

    get userName() {
        return this.data.get("userName");
    }

    get userSigninCount() {
        if (this.data.has("userSigninCount")) {
            return parseInt(this.data.get("userSigninCount"))
        } else {
            return 0
        }
    }

    get eventsLiked() {
        if (this.data.has("eventsLiked")) {
            return parseInt(this.data.get("eventsLiked"))
        } else {
            return 0
        }
    }

    set eventsLiked(value) {
        this.data.set("eventsLiked", value);
    }

    get eventsToTrain() {
        return parseInt(this.data.get("eventsToTrain"));
    }

    set eventsToTrain(value) {
        this.data.set("eventsToTrain", value);
    }

}
