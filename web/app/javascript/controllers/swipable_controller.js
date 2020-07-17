import ApplicationController from "./application_controller"

export default class SwipableController extends ApplicationController {
    static targets = ["swipable", "onboarding", "items", "skip"];

    async connect() {
        const {BotModule}      = await import("../modules/bot-module")
        const {SwipableModule} = await import("../modules/swipable-module")

        this.bot      = BotModule;
        this.swipable = SwipableModule;

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
        if ((this.userSigninCount <= 1 && this.userTasteEventsSaved < 1) && this.botOn) {
            this.showBot();
        } else {
            if (this.hasSwipableTarget) {
                this.showSwipe();
            }
        }
    }

    teardown() {
        this.bot.destroy();
        this.swipable.destroy();
    }

    showBot() {
        this.bot.init(this.onboardingTarget)

        this.hidden = false;

        this.bot
            .message({
                         content: `Olá ${this.userName} 👋`,
                         delay:   150
                     })
            .then(ok =>
                      this.bot.message({
                                           cssClass: "no-icon",
                                           content:
                                                     "Vamos aproveitar a cidade de Porto Alegre juntos!",
                                           delay:    2000
                                       })
            )
            .then(ok =>
                      this.bot.message({
                                           cssClass: "no-icon",
                                           content:
                                                     "Inicialmente vamos te sugerir eventos, mas logo também iremos sugerir filmes no cinema, serviços, promoções e experiências",
                                           delay:    1500
                                       }))
            .then(ok =>
                      this.bot.message({
                                           cssClass: "no-icon",
                                           content:
                                                     "Chega de papo, vamos começar!",
                                           delay:    4000
                                       })
            )
            .then(ok =>
                      this.bot.message({
                                           cssClass: "no-icon",
                                           content:
                                                     "Para sugerir eventos que tem a ver com você, primeiro me diga o que você gosta e não gosta",
                                           delay:    1000
                                       })
            )
            .then(ok =>
                      this.bot.message({
                                           cssClass: "no-icon",
                                           content:  "Vamos lá?",
                                           delay:    4000
                                       })
            )
            .then(ok =>
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
            )
            .then(ok =>
                      this.bot.message({
                                           delay:   250,
                                           human:   true,
                                           content: ok
                                       })
            )
            .then(ok => {
                this.bot.message({
                                     content: "Carregando opções...",
                                     delay:   1500
                                 })
            })
            .then(ok => {
                setTimeout(() => {
                    requestAnimationFrame(() => {
                        this.onboardingTarget.style.opacity = 0;
                        setTimeout(() => {
                            if (this.hasSwipableTarget) {
                                this.showSwipe();
                            }
                        }, 450)

                    });
                }, 4000);
            })
            .catch(error => console.log("error", error));
    }

    showSwipe() {
        this.botOn                          = false;
        this.hidden                         = false;
        this.onboardingTarget.style.display = "none";
        this.itemsTarget.style.opacity      = 1;
        this.swipable.init();
        this.itemsTarget.style.display = "block";
    }

    get userName() {
        return this.data.get("userName");
    }

    get userSigninCount() {
        return JSON.parse(this.data.get("userSigninCount"))
    }

    get userTasteEventsSaved() {
        return JSON.parse(this.data.get("userTasteEventsSaved"))
    }

    get botOn() {
        return JSON.parse(this.data.get("botOn"))
    }

    set botOn(value) {
        this.data.set("botOn", value);
    }

    get hidden() {
        return JSON.parse(this.data.get("hidden"))
    }

    set hidden(value) {
        setTimeout(() => {
            requestIdleCallback(() => {
                requestAnimationFrame(() => {
                    this.data.set("hidden", value);
                })
            })
        }, 500)
    }
}
