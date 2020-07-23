import {MobileDetector} from "../modules/mobile-detector-module";
import "./serviceworker-companion";

window.addEventListener("beforeinstallprompt", (e) => {
    e.preventDefault();
    let deferredPrompt = e;
    const btnAdd       = document.querySelector(".demo__pwaBanner");

    if (btnAdd) {
        btnAdd.addEventListener("click", (e) => {
            deferredPrompt.prompt();

            deferredPrompt.userChoice.then((choiceResult) => {
                if (choiceResult.outcome === "accepted") {
                    console.log("User accepted the A2HS prompt");
                } else {
                    console.log("User dismissed the A2HS prompt");
                }
                deferredPrompt = null;
            });
        });
    }
});

document.addEventListener("DOMContentLoaded", function () {

    WebFont.load({
                     google: {
                         families: ["Montserrat:400,500,600,700", "Roboto:400,500,700"]
                     }
                 });

    document.querySelectorAll(".js-logo");
    const answerEl           = document.querySelector(".answer");
    const shareBtn           = document.querySelector(".shareBtn");
    const inviteFloatEl      = document.querySelector(".invite-float");
    const androidEl          = document.querySelector(".android");
    const heroBannerEl       = document.querySelector(".hero__banner");


    if (androidEl) {
        setTimeout(() => {
            requestAnimationFrame(() => {
                androidEl.style.transform  = "translateY(0)";
                heroBannerEl.style.opacity = 1;
            });
        }, 1000);
    }

    if (inviteFloatEl) {
        window.addEventListener("scroll", () => {
            if (window.scrollY > 500) {
                requestAnimationFrame(() => {
                    inviteFloatEl.style.opacity    = 1;
                    inviteFloatEl.style.transform  = "translateY(0)";
                    inviteFloatEl.style.visibility = "visible";
                });
            } else {
                requestAnimationFrame(() => {
                    inviteFloatEl.style.opacity    = 1;
                    inviteFloatEl.style.transform  = "translateY(150px)";
                    inviteFloatEl.style.visibility = "hidden";
                });
            }
        }, {
                                    capture: false,
                                    passive: true
                                });
    }

    if (!MobileDetector.mobile()) {
        setTimeout(() => {
            const scrollOptions = {
                capture: false,
                passive: true
            };

            const onScroll = target => {
                requestAnimationFrame(() => {
                    document.querySelector(".how-works").style.setProperty("--y", `${window.scrollY}px`)
                });
            };

            document.querySelectorAll(".how-works__step").forEach((step) => {
                step.style.setProperty("--offsettop", `${step.offsetTop}px`);
            })

            window.addEventListener("scroll", onScroll, scrollOptions)
        }, 2000);
    }


    const videos = document.querySelectorAll("video");

    if ("IntersectionObserver" in window) {
        const observer = new IntersectionObserver((entries, observer) => {
                                                      for (const entry of entries) {
                                                          if (entry.isIntersecting) {
                                                              requestIdleCallback(() => {
                                                                  entry.target.play();
                                                              }, {timeout: 250});
                                                          } else {
                                                              requestIdleCallback(() => {
                                                                  entry.target.pause();
                                                              }, {timeout: 250});
                                                          }
                                                      }
                                                  },
                                                  {
                                                      threshold: [0.50]
                                                  }
        );

        videos.forEach((video) => {
            observer.observe(video);
        });
    } else {
        videos.forEach((video) => {
            video.play();
        });
    }


    if (navigator.share) {
        shareBtn.onclick = () => {
            navigator.share({
                                title: "Alegreme - Aproveite a cidade de Porto Alegre",
                                text:  "Atividades culturais, meetups, shows, rolês, feiras de rua, aquele filme no Mario Quintana...\n",
                                url:   "https://alegreme.com",
                            }).then(() => console.log("Valeu\"")).catch((error) => console.log("Deu erro ai :(", error));
        };
    } else {
        shareBtn.style.display = "none";
    }


    if (answerEl) {
        answerEl.addEventListener("click", () => {
            answerEl.classList.add("is-showout");

            setTimeout(() => {
                answerEl.style.display = "none";
                answerEl.classList.remove("is-showout");
                answerEl.querySelectorAll("[data-answer]").forEach((answer) => {
                    answer.style.display = "none";

                });
                document.body.style.overflow = "auto";

                if (MobileDetector.mobile()) {
                } else {
                    document.body.style.paddingRight = "0";
                }

            }, 590);
        });
    }
});
